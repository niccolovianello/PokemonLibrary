//
//  Model.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 06/06/25.
//

import Foundation

struct Response: Codable {
    let count: Int?
    let next: String?
    let results: [PokemonResult]?
}

// MARK: - Result
struct PokemonResult: Codable, Identifiable {
    let id: String = UUID().uuidString
    let name: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

struct Pokemon: Codable, Hashable {
    let abilities: [Ability]
    let baseExperience: Int
    let height: Int
    let id: Int
    let isDefault: Bool
    let locationAreaEncounters: String
    let name: String
    let order: Int
    let sprites: Sprites
    let weight: Int
}

struct Ability: Codable, Hashable {
    let ability: Species?
    let isHidden: Bool
    let slot: Int
}

struct Species: Codable, Hashable {
    let name: String
    let url: String
}

struct Sprites: Codable, Hashable {
    let backDefault: String
    let backShiny: String
    let frontDefault: String
    let frontShiny: String
    let other: Other?
}

struct Other: Codable, Hashable {
    let officialArtwork: OfficialArtwork
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable, Hashable {
    let frontDefault, frontShiny: String
}
