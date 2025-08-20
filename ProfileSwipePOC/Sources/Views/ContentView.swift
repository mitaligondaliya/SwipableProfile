//
//  ContentView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

// MARK: - Main Swipe Screen
// MARK: - Main Swipe Screen
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedProfile: Profile?

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient Background
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.6),
                        Color.blue.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(error: error) {
                            Task { await viewModel.fetchProfiles() }
                        }
                    } else if viewModel.profiles.isEmpty {
                        EmptyProfilesView {
                            Task { await viewModel.fetchProfiles() }
                        }
                    } else {
                        // Cards
                        ZStack {
                            ForEach(viewModel.profiles.reversed()) { profile in
                                SwipeCardView(profile: profile) { direction, profile in
                                    handleSwipe(direction, profile: profile)
                                }
                                .onTapGesture { selectedProfile = profile }
                            }
                        }
                        .padding()

                        // Bottom Controls
                        BottomControls(
                            onDislike: { triggerSwipe(.left) },
                            onSuperLike: { triggerSwipe(.up) },
                            onLike: { triggerSwipe(.right) }
                        )
                        .padding(.top, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .task { await viewModel.fetchProfiles() }
            .sheet(item: $selectedProfile) { profile in
                ProfileDetailView(profile: profile, isPresented: $selectedProfile)
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func handleSwipe(_ direction: SwipeDirection, profile: Profile) {
        switch direction {
        case .right: print("✅ Liked \(profile.name)")
        case .left: print("❌ Disliked \(profile.name)")
        case .up: print("⭐ SuperLiked \(profile.name)")
        }
        viewModel.removeProfile(profile)
    }

    private func triggerSwipe(_ direction: SwipeDirection) {
        guard let topProfile = viewModel.profiles.first else { return }
        handleSwipe(direction, profile: topProfile)
    }
}

// MARK: - Subviews

struct LoadingView: View {
    var body: some View {
        ProgressView("Loading Profiles...")
            .font(.title2)
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(error)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct EmptyProfilesView: View {
    let reloadAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("You're all caught up 🎉")
                .font(.title2)
                .fontWeight(.semibold)
            Button("Reload Profiles", action: reloadAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct BottomControls: View {
    let onDislike: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            Button(action: onDislike) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.red)
            }
            Button(action: onSuperLike) {
                Image(systemName: "star.circle.fill")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.blue)
            }
            Button(action: onLike) {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
