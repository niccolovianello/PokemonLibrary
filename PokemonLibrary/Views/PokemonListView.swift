//
//  ContentView.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 06/06/25.
//

import SwiftUI

@MainActor
@Observable
final class ContentViewModel {
    
    enum LoadingState: Equatable {
        case idle
        case willLoadMore
        case error(String)
        case success
    }
    
    var fetchedPokemon: [PokemonResult] = []
    var showedPokemon: [PokemonResult] = []
    var searchedPokemon: Pokemon?
    let itemThreshold = 2
    var currentPageIndex: Int = 0
    var currentLimit: Int = 20
    
    var searchText: String = ""
    
    var loadingState: LoadingState = .idle
    
    func getInitialData() async throws {
        
        if !fetchedPokemon.isEmpty { return }
        
        loadingState = .willLoadMore
        fetchedPokemon = try await getPage()
        showedPokemon = fetchedPokemon
    }
    
    func filterPokemon() {
        guard !searchText.isEmpty else {
            showedPokemon = fetchedPokemon
            return
        }
        self.showedPokemon = fetchedPokemon.filter { pokemon in
            pokemon.name?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }
    
    func getNextPage() async throws {
        currentPageIndex += 1
        loadingState = .willLoadMore
        let newElements = try await getPage(pageIndex: currentPageIndex, limit: currentLimit)
        fetchedPokemon.append(contentsOf: newElements)
        showedPokemon = fetchedPokemon
    }
    
    nonisolated private func getPage(pageIndex: Int = 0, limit: Int = 20) async throws -> [PokemonResult] {
        do {
            let res = try await APIHelper().fetchPage(pageIndex: pageIndex, limit: limit)
            
            guard let res else {
                await MainActor.run {
                    loadingState = .error("Error fetching data")
                }
                return []
            }
            
            await MainActor.run {
                loadingState = .success
                update(pageIndex: pageIndex, limit: limit)
            }
            return res
            
        } catch {
            throw APIError.invalidResponse
        }
    }
    
    private func update(pageIndex: Int, limit: Int) {
        currentPageIndex = pageIndex
        currentLimit = limit
    }
}

struct PokemonListView: View {
    
    @State private var viewModel = ContentViewModel()
    
    @State private var isPokemonDetailViewPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.loadingState {
                case .idle:
                    EmptyView()
                    
                case .error(_):
                    VStack {
                        Text("Error loading data")
                            .font(.headline)
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    .foregroundStyle(.red)
                    
                case .success, .willLoadMore:
                    ScrollViewReader { proxy in
                        List {
                            ForEach(viewModel.showedPokemon) { pokemon in
                                if let name = pokemon.name {
                                    NavigationLink(name.capitalized, value: name)
                                        .onAppear {
                                            loadMoreIfNeeded(currentItem: pokemon) {
                                                Task {
                                                    try await viewModel.getNextPage()
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        .refreshable {
                            try? await viewModel.getInitialData()
                        }
                        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search Pokémon")
                        .onChange(of: viewModel.searchText) {
                            viewModel.filterPokemon()
                        }
                        .onSubmit(of: .search) {
                            isPokemonDetailViewPresented = true
                        }
                        .navigationDestination(for: String.self) { name in
                            PokemonDetailView(name: name)
                        }
                        .sheet(isPresented: $isPokemonDetailViewPresented) {
                            PokemonDetailView(name: viewModel.searchText)
                        }
                        .scrollIndicators(.hidden)
                    }
                    
                    if viewModel.loadingState == .willLoadMore {
                        ProgressView("Loading more Pokémon...")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding(.vertical)
                    }
                }
            }
            .task {
                try? await viewModel.getInitialData()
            }
            .navigationTitle("Pokémon")
        }
    }
    
    private func loadMoreIfNeeded(currentItem: PokemonResult, onLoadMore: (() -> Void)? = nil) {
        guard viewModel.loadingState != .willLoadMore, currentItem.name == viewModel.fetchedPokemon.last?.name else { return }
        onLoadMore?()
    }
}

#Preview {
    PokemonListView()
}
