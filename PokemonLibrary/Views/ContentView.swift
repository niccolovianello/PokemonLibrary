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
    
    var pokemon: [PokemonResult] = []
    let itemThreshold = 2
    var currentPageIndex: Int = 0
    var currentLimit: Int = 20
    
    var loadingState: LoadingState = .idle
    
    func getInitialData() async throws {
        
        if !pokemon.isEmpty { return }
        
        loadingState = .willLoadMore
        pokemon = try await getPage()
    }
    
    func getNextPage() async throws {
        currentPageIndex += 1
        loadingState = .willLoadMore
        let newElements = try await getPage(pageIndex: currentPageIndex, limit: currentLimit)
        pokemon.append(contentsOf: newElements)
    }
    
    private func getPage(pageIndex: Int = 0, limit: Int = 20) async throws -> [PokemonResult] {
        do {
            let res = try await APIHelper().fetchPage(pageIndex: pageIndex, limit: limit)
            
            guard let res else {
                loadingState = .error("Error fetching data")
                return []
            }
            loadingState = .success
            update(pageIndex: pageIndex, limit: limit)
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

struct ContentView: View {
    
    @State private var viewModel = ContentViewModel()
    
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
                            ForEach(viewModel.pokemon) { pokemon in
                                if let name = pokemon.name {
                                    NavigationLink(name.capitalized, value: pokemon.url)
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
                        .navigationDestination(for: String.self) { url in
                            PokemonView(urlString: url)
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
        guard viewModel.loadingState != .willLoadMore, currentItem.name == viewModel.pokemon.last?.name else { return }
        onLoadMore?()
    }
}

#Preview {
    ContentView()
}
