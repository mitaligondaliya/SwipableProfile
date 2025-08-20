//
//  SwipeCardView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import SwiftUI

// MARK: - Swipe Card View
struct SwipeCardView: View {
    let profile: Profile
    let onSwipe: (SwipeDirection, Profile) -> Void

    @State private var offset: CGSize = .zero
    @GestureState private var isDragging = false
    private let swipeThreshold: CGFloat = 120

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Profile Image
                Image(profile.imageName ?? "placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // Gradient Overlay
                LinearGradient(
                    colors: [Color.black.opacity(0.6), Color.clear],
                    startPoint: .bottom,
                    endPoint: .center
                )

                // Profile Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let bio = profile.bio {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }
                .padding()
            }
            .cornerRadius(20)
            .shadow(radius: 8)
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        handleDragEnd(gesture: gesture, geo: geo)
                    }
            )
            .animation(.spring(), value: offset)

            // Like / Dislike / SuperLike Overlays
            .overlay(alignment: .topLeading) {
                if offset.width > 50 {
                    SwipeOverlayLabel(text: "LIKE", color: .green, rotation: -20)
                        .padding(30)
                } else if offset.width < -50 {
                    SwipeOverlayLabel(text: "NOPE", color: .red, rotation: 20)
                        .padding(30)
                } else if offset.height < -50 {
                    SwipeOverlayLabel(text: "SUPER LIKE", color: .blue, rotation: 0)
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func handleDragEnd(gesture: DragGesture.Value, geo: GeometryProxy) {
        let drag = gesture.translation
        if drag.width > swipeThreshold {
            // Swiped Right
            withAnimation(.spring()) {
                offset = CGSize(width: geo.size.width * 2, height: drag.height)
            }
            onSwipe(.swipeRight, profile)
        } else if drag.width < -swipeThreshold {
            // Swiped Left
            withAnimation(.spring()) {
                offset = CGSize(width: -geo.size.width * 2, height: drag.height)
            }
            onSwipe(.swipeLeft, profile)
        } else if drag.height < -swipeThreshold {
            // Swiped Up
            withAnimation(.spring()) {
                offset = CGSize(width: 0, height: -geo.size.height * 2)
            }
            onSwipe(.swipeUP, profile)
        } else {
            // Reset if not swiped enough
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
}

// MARK: - Swipe Overlay Label
struct SwipeOverlayLabel: View {
    let text: String
    let color: Color
    let rotation: Double

    var body: some View {
        Text(text)
            .font(.system(size: 36, weight: .bold))
            .padding(12)
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 4)
            )
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Preview
#Preview {
    SwipeCardView(
        profile: Profile(
            name: "Mitali",
            age: 30,
            bio: "iOS Engineer | Loves SwiftUI & Travel ✈️",
            imageName: "placeholder",
            interests: ["Coding", "Travel", "Cooking"],
            distance: 5.2,
            occupation: "iOS Developer",
            education: "CS Graduate",
            location: "India"
        )
    ) { _, _ in }
    .padding()
}
