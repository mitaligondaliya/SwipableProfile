//
//  ProfileService 2.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import Foundation

// MARK: - Profile Service
protocol ProfileServiceProtocol {
    func fetchProfiles() async throws -> [Profile]
}

final class ProfileService: ProfileServiceProtocol {
    func fetchProfiles() async throws -> [Profile] {
        guard let url = Bundle.main.url(forResource: "profiles", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        let data = try Data(contentsOf: url)

        // Debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Loaded JSON:\n\(jsonString)")
        }

        do {
            return try JSONDecoder().decode([Profile].self, from: data)
        } catch {
            print("Decoding failed: \(error)")
            throw error
        }
    }
}
