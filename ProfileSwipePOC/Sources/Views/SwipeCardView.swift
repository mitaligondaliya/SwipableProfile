//
//  SwipeCardView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

// MARK: - Swipe Card View
import SwiftUI

struct SwipeCardView: View {
    let profile: Profile
    let onSwipe: (SwipeDirection, Profile) -> Void

    @State private var offset: CGSize = .zero
    @GestureState private var isDragging = false

    private let swipeThreshold: CGFloat = 120

    var body: some View {
        ZStack {
            // MARK: - Card Background
            ZStack(alignment: .bottomLeading) {
                Image(profile.imageName ?? "placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 420)
                    .clipped()
                    .cornerRadius(20)

                // Gradient for text contrast
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(20)

                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.name)
                        .font(.title)
                        .bold()
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

            // MARK: - Overlay Badges
            if offset.width > 0 {
                BadgeView(text: "LIKE", color: .green)
                    .rotationEffect(.degrees(-20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(30)
                    .opacity(min(Double(offset.width / 100), 1))
            } else if offset.width < 0 {
                BadgeView(text: "NOPE", color: .red)
                    .rotationEffect(.degrees(20))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(30)
                    .opacity(min(Double(-offset.width / 100), 1))
            } else if offset.height < 0 {
                BadgeView(text: "SUPER LIKE", color: .blue, fontSize: 28)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 60)
                    .opacity(min(Double(-offset.height / 100), 1))
            }
        }
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .scaleEffect(isDragging ? 1.02 : 1)
        .opacity(1 - Double(abs(offset.width) / 400))
        .gesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    handleSwipe(gesture)
                }
        )
        .animation(.spring(), value: offset)
    }

    // MARK: - Handle Swipe 
    private func handleSwipe(_ gesture: DragGesture.Value) {
        if abs(gesture.translation.width) > swipeThreshold {
            // Left or Right Swipe
            let direction: SwipeDirection = gesture.translation.width > 0 ? .right : .left
            withAnimation(.spring()) {
                offset = CGSize(width: gesture.translation.width * 2, height: gesture.translation.height)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipe(direction, profile)
                offset = .zero
            }
        } else if gesture.translation.height < -swipeThreshold {
            // Super Like Swipe
            withAnimation(.spring()) {
                offset = CGSize(width: 0, height: -800)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipe(.up, profile)
                offset = .zero
            }
        } else {
            // Bounce back if threshold not met
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                offset = .zero
            }
        }
    }
}

// MARK: - Reusable Badge
struct BadgeView: View {
    let text: String
    let color: Color
    var fontSize: CGFloat = 40

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(color)
            .padding(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 4))
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
