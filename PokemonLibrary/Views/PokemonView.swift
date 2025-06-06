//
//  PokemonView.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 06/06/25.
//

import SwiftUI

@MainActor
@Observable
final class PokemonViewModel {
    
    let apiHelper = APIHelper()
    var pokemon: Pokemon?
    
    func getPokemon(urlString: String?) async throws {
        pokemon = try await apiHelper.fetchPokemon(urlString: urlString)
    }
    
}

struct PokemonView: View {
    
    @State private var viewModel = PokemonViewModel()
    
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
                        .shadow(radius: 10)
                }
            }
        }
        .task {
            try? await viewModel.getPokemon(urlString: urlString)
        }
    }
}

struct ImageLoaderView: View {
    
    var url: String
    var contentMode: ContentMode = .fill
    var size: CGFloat = 100
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } placeholder: {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
    }
    
}

#Preview {
    PokemonView()
}
