//
//  ContentView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedProfile: Profile?
    @State private var topSwipe: SwipeDirection?

    private enum ScreenState {
        case loading, empty, content
        case error(String)
    }

    private var screenState: ScreenState {
        if viewModel.isLoading { return .loading }
        if let err = viewModel.errorMessage { return .error(err) }
        if viewModel.profiles.isEmpty { return .empty }
        return .content
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradient().ignoresSafeArea()

                // MAIN AREA
                Group {
                    switch screenState {
                    case .loading:
                        LoadingView()

                    case .error(let message):
                        ErrorView(error: message) { Task { await viewModel.fetchProfiles() } }

                    case .empty:
                        EmptyProfilesView {
                            Task { await viewModel.fetchProfiles() }
                        }

                    case .content:
                        cards
                            .transition(.opacity)
                    }
                }
                // Ensure all non-content states are centered
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal)
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.fetchProfiles() }
            .refreshable { await viewModel.fetchProfiles() }

            // BOTTOM CONTROLS: live in their own inset so they never overlap cards
            .safeAreaInset(edge: .bottom) {
                if case .content = screenState {
                    BottomControls(
                        onDislike: { triggerSwipe(.swipeLeft) },
                        onSuperLike: { triggerSwipe(.swipeUp) },
                        onLike: { triggerSwipe(.swipeRight) }
                    )
                    .padding(.vertical, 10)
                }
            }
            .sheet(item: $selectedProfile) { profile in
                ProfileDetailView(profile: profile, selectedProfile: $selectedProfile)
            }
        }
    }

    // MARK: - Cards
    private var cards: some View {
        ZStack {
            ForEach(viewModel.profiles.reversed()) { profile in
                SwipeCardView(
                    profile: profile,
                    onSwipe: { direction, profile in
                        handleSwipe(direction, profile: profile)
                    },
                    programmaticSwipe: Binding(
                        get: { profile.id == viewModel.profiles.first?.id ? topSwipe : nil },
                        set: { _ in topSwipe = nil }
                    )
                )
                .onTapGesture { selectedProfile = profile }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        // No extra bottom padding needed because the controls live in an inset
        .padding(.vertical)
        .animation(.snappy(duration: 0.35), value: viewModel.profiles)
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
        guard viewModel.profiles.first != nil else { return }
        topSwipe = direction
    }
}

// Keep your existing BackgroundGradient / views as-is
private struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Subviews
struct LoadingView: View {
    var body: some View {
        ProgressView("Loading Profiles…")
            .font(.title2)
            .accessibilityLabel("Loading profiles")
            .padding()
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
                .contentShape(Circle())
                .accessibilityAddTraits(.isButton)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
