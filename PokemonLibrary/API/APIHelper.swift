//
//  APIHelper.swift
//  PokemonLibrary
//
//  Created by Niccolò Vianello on 06/06/25.
//

import Foundation

enum APIError: Error {
    case invalidResponse
}

actor APIHelper {
    
    internal struct QueryParams {
        var params: [String: String]
    }
    
    internal class URLBuilder {
        
        var components = URLComponents()
        
        init() {
            components.scheme = Constants.scheme
            components.host = Constants.host
            components.path = Constants.path
        }
        
        func buildURL(with queryParams: QueryParams) -> URL? {
            
            var items = [URLQueryItem]()
            
            for (key, value) in queryParams.params {
                items.append(URLQueryItem(name: key, value: value))
            }
            
            components.queryItems = items
            
            return components.url
        }
    }
    
    func fetchPage(pageIndex: Int = 0, limit: Int = 20) async throws -> [PokemonResult]? {
        
        let params = buildParams(params: [
            "limit": "\(limit)",
            "offset": "\(pageIndex * limit)"
        ])
        
        let finalUrl = URLBuilder().buildURL(with: params)
        
        guard let finalUrl else {
            throw URLError(.badURL)
        }
        
        guard let data = try await makeRequest(finalUrl: finalUrl) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(Response.self, from: data)
            return result.results
        } catch let error {
            print("Could not decode JSON: \(error)")
            throw error
        }
    }
    
    func fetchPokemon(urlString: String?) async throws -> Pokemon {
        guard let urlString,
              let finalUrl = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        guard let data = try await makeRequest(finalUrl: finalUrl) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(Pokemon.self, from: data)
            return result
        } catch let error {
            print("Could not decode JSON: \(error)")
            throw error
        }
    }
    
    private func buildParams(params: [String: String]) -> QueryParams {
        QueryParams(params: params)
    }
    
    private func makeRequest(finalUrl: URL) async throws -> Data? {
        let request = URLRequest(url: finalUrl)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Simulate delayed response
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            return nil
        }
        
        return data
    }
    
}
