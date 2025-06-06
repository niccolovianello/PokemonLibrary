//
//  ImageLoaderView.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 06/06/25.
//

import SwiftUI

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
