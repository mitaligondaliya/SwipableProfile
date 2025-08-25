//
//  ContentView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import SwiftUI

// MARK: - Main Swipe Screen
struct ContentView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedProfile: Profile?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient()

                VStack {
                    StateRenderer(
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.errorMessage,
                        isEmpty: viewModel.profiles.isEmpty,
                        loadingView: { LoadingView() },
                        errorView: { err in
                            ErrorView(error: err) { Task { await viewModel.fetchProfiles() } }
                        },
                        emptyView: {
                            EmptyProfilesView { Task { await viewModel.fetchProfiles() } }
                        },
                        content: { cards }
                    )

                    if !viewModel.isLoading && viewModel.errorMessage == nil && !viewModel.profiles.isEmpty {
                        BottomControls(
                            onDislike: { triggerSwipe(.swipeLeft) },
                            onSuperLike: { triggerSwipe(.swipeUp) },
                            onLike: { triggerSwipe(.swipeRight) }
                        )
                        .padding(.top, 20)
                        .transition(.opacity)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.fetchProfiles() }
            .refreshable { await viewModel.fetchProfiles() }
            .sheet(item: $selectedProfile) { profile in
                ProfileDetailView(profile: profile, selectedProfile: $selectedProfile)
            }
        }
    }

    // MARK: - Cards
    private var cards: some View {
        ZStack {
            ForEach(viewModel.profiles.reversed()) { profile in
                SwipeCardView(profile: profile) { direction, profile in
                    handleSwipe(direction, profile: profile)
                }
                .onTapGesture { selectedProfile = profile }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity))
                )
            }
        }
        .padding()
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.profiles)
    }

    // MARK: - Actions
    private func handleSwipe(_ direction: SwipeDirection, profile: Profile) {
        switch direction {
        case .swipeRight: print("✅ Liked \(profile.name)")
        case .swipeLeft:  print("❌ Disliked \(profile.name)")
        case .swipeUp:    print("⭐ SuperLiked \(profile.name)")
        }
        viewModel.removeProfile(profile)
    }

    private func triggerSwipe(_ direction: SwipeDirection) {
        guard let topProfile = viewModel.profiles.first else { return }
        handleSwipe(direction, profile: topProfile)
    }
}

// MARK: - Background
private struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - State Renderer
/// A tiny helper that keeps `ContentView`'s body clean.
private struct StateRenderer<Loading: View, ErrorV: View, Empty: View, Content: View>: View {
    let isLoading: Bool
    let errorMessage: String?
    let isEmpty: Bool
    @ViewBuilder var loadingView: () -> Loading
    @ViewBuilder var errorView: (String) -> ErrorV
    @ViewBuilder var emptyView: () -> Empty
    @ViewBuilder var content: () -> Content

    var body: some View {
        if isLoading {
            loadingView()
        } else if let errorMessage {
            errorView(errorMessage)
        } else if isEmpty {
            emptyView()
        } else {
            content()
        }
    }
}

// MARK: - Subviews
struct LoadingView: View {
    var body: some View {
        ProgressView("Loading Profiles…")
            .font(.title2)
            .accessibilityLabel("Loading profiles")
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
                .accessibilityLabel("Error: \(error)")
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Attempts to load profiles again")
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

// MARK: - Bottom Controls
struct BottomControls: View {
    let onDislike: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            RoundIconButton(systemName: "xmark.circle.fill", action: onDislike)
                .foregroundColor(.red)
                .accessibilityLabel("Dislike")

            RoundIconButton(systemName: "star.circle.fill", action: onSuperLike)
                .foregroundColor(.blue)
                .accessibilityLabel("Super like")

            RoundIconButton(systemName: "heart.circle.fill", action: onLike)
                .foregroundColor(.green)
                .accessibilityLabel("Like")
        }
    }
}

private struct RoundIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 55, height: 55)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
