//
//  ErrorView.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 10/06/25.
//

import SwiftUI

struct ErrorView: View {
    
    var message = "Error"
    var detailedDescription: String?
    var imageSysyemName = "exclamationmark.triangle.fill"
    
    var body: some View {
        VStack {
            Text(message)
                .font(.headline)
            if let detailedDescription {
                Text(detailedDescription)
                    .font(.caption)
            }
            
            Image(systemName: imageSysyemName)
        }
    }
}

#Preview {
    ErrorView()
}
