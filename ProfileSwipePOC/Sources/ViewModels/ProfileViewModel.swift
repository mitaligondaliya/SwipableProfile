//
//  ProfileViewModel.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import Foundation
import SwiftUI

// MARK: - Profile ViewModel
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: ProfileServiceProtocol

    init(service: ProfileServiceProtocol = ProfileService()) {
        self.service = service
    }

    func fetchProfiles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedProfiles = try await service.fetchProfiles()
            self.profiles = fetchedProfiles
        } catch {
            self.errorMessage = "Failed to load profiles: \(error.localizedDescription)"
        }
    }

    func removeProfile(_ profile: Profile) {
        withAnimation {
            profiles.removeAll { $0.id == profile.id }
        }
    }
}
