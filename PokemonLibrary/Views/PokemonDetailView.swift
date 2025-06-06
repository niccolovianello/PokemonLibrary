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
    
    let apiHelper = APIHelper()
    var pokemon: Pokemon?
    
    func getPokemon(urlString: String?) async throws {
        pokemon = try await apiHelper.fetchPokemon(urlString: urlString)
    }
    
}

struct PokemonDetailView: View {
    
    @State private var viewModel = PokemonDetailViewModel()
    
    var urlString: String?
    
    var body: some View {
        VStack {
            if let pokemon = viewModel.pokemon,
               let imageUrl = pokemon.sprites.other?.officialArtwork.frontShiny {
                ZStack {
                    Rectangle()
                        .foregroundColor(.green)
                        .ignoresSafeArea()
                    
                    ImageLoaderView(url: imageUrl, size: 260)
                }
            }
        }
        .task {
            try? await viewModel.getPokemon(urlString: urlString)
        }
    }
}

#Preview {
    PokemonDetailView()
}
