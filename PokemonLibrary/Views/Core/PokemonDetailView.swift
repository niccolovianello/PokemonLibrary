//
//  PokemonView.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 06/06/25.
//

import SwiftUI

@MainActor
@Observable
final class PokemonDetailViewModel {
    
    enum LoadingState {
        case idle
        case loading
        case success
        case failed
    }
    
    let apiHelper = APIHelper()
    var pokemon: Pokemon?
    var loadingState: LoadingState = .idle
    
    func getPokemon(name: String) async throws {
        loadingState = .loading
        do {
            pokemon = try await apiHelper.fetchPokemon(named: name)
            loadingState = .success
        } catch {
            loadingState = .failed
        }
    }
    
}

struct PokemonDetailView: View {
    
    @State private var viewModel = PokemonDetailViewModel()
    var name: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(randomColor())
                .ignoresSafeArea()
            
            switch viewModel.loadingState {
                case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .success:
                if let pokemon = viewModel.pokemon,
                   let imageUrl = pokemon.sprites.other?.officialArtwork.frontDefault {
                    
                    ImageLoaderView(url: imageUrl, size: 260)
                }
            case .failed:
                ErrorView(message: "A Pokémon with this name doesn't exist!")
            }
        }
        .task {
            try? await viewModel.getPokemon(name: name)
        }
    }
    
    func randomColor() -> Color {
        print("Generating random color...")
        return Color(.sRGB, red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

#Preview {
    PokemonDetailView(name: "bulbasaur")
}
