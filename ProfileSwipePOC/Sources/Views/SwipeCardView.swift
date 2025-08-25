//
//  SwipeCardView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import SwiftUI

// MARK: - Swipe Direction helper
extension SwipeDirection {
    static func from(drag: CGSize, threshold: CGFloat) -> SwipeDirection? {
        if drag.width > threshold { return .swipeRight }
        if drag.width < -threshold { return .swipeLeft }
        if drag.height < -threshold { return .swipeUp }
        return nil
    }
}

// MARK: - Config
private struct SwipeConfig {
    let swipeThreshold: CGFloat = 120
    let likeShowThreshold: CGFloat = 50
    let nopeShowThreshold: CGFloat = -50
    let superLikeShowThreshold: CGFloat = -50
    let cornerRadius: CGFloat = 20
    let shadowRadius: CGFloat = 8
    let maxRotation: CGFloat = 20
    let rotationDivisor: CGFloat = 15
    let gradientMaxHeight: CGFloat = 220
    let gradientFraction: CGFloat = 0.45
}

// MARK: - Swipe Card View
struct SwipeCardView: View {
    let profile: Profile
    let onSwipe: (SwipeDirection, Profile) -> Void

    @State private var offset: CGSize = .zero
    @GestureState private var isDragging = false

    private let cfg = SwipeConfig()

    var body: some View {
        GeometryReader { geo in
            let gradientHeight = min(cfg.gradientMaxHeight, geo.size.height * cfg.gradientFraction)

            ZStack {
                // Base
                Image(profile.imageName ?? "placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.black.opacity(0.6), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: gradientHeight)
                        .allowsHitTesting(false)
                    }

                // Info
                infoSection
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .allowsHitTesting(false)

                // Badges on top
                overlayBadges()
                    .allowsHitTesting(false)
            }
            .cardChrome(radius: cfg.cornerRadius, shadow: cfg.shadowRadius) // Uses ViewModifier
            .offset(offset)
            .rotationEffect(rotationAngle)
            .gesture(dragGesture(geo))
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: offset)
        }
    }

    // MARK: - Sections
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(profile.name)
                .font(.title).bold()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if let bio = profile.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(profile.name)\(profile.bio != nil ? ", bio available" : "")"))
    }

    @ViewBuilder
    private func overlayBadges() -> some View {
        ZStack {
            if offset.width > cfg.likeShowThreshold {
                SwipeOverlayLabel(style: .like, rotation: -20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(30)
            } else if offset.width < cfg.nopeShowThreshold {
                SwipeOverlayLabel(style: .nope, rotation: 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(30)
            }
            
            if offset.height < cfg.superLikeShowThreshold && abs(offset.width) < cfg.likeShowThreshold {
                SwipeOverlayLabel(style: .superLike, rotation: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 100)
            }
        }
    }

    // MARK: - Rotation
    private var rotationAngle: Angle {
        let raw = offset.width / cfg.rotationDivisor
        let clamped = max(-cfg.maxRotation, min(cfg.maxRotation, raw))
        return .degrees(Double(clamped))
    }

    // MARK: - Gesture
    private func dragGesture(_ geo: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { gesture in offset = gesture.translation }
            .onEnded { gesture in handleDragEnd(gesture: gesture, geo: geo) }
    }

    private func handleDragEnd(gesture: DragGesture.Value, geo: GeometryProxy) {
        let drag = gesture.translation
        guard let direction = SwipeDirection.from(drag: drag, threshold: cfg.swipeThreshold) else {
            withAnimation(.spring()) { offset = .zero }
            return
        }
        commitSwipe(direction, geo: geo, drag: drag)
    }

    private func commitSwipe(_ direction: SwipeDirection, geo: GeometryProxy, drag: CGSize) {
        withAnimation(.spring()) {
            offset = offscreenOffset(for: direction, in: geo, drag: drag)
        }
        onSwipe(direction, profile)
    }

    private func offscreenOffset(for direction: SwipeDirection, in geo: GeometryProxy, drag: CGSize) -> CGSize {
        switch direction {
        case .swipeRight:
            return .init(width: geo.size.width * 2, height: drag.height)
        case .swipeLeft:
            return .init(width: -geo.size.width * 2, height: drag.height)
        case .swipeUp:
            return .init(width: 0, height: -geo.size.height * 2)
        }
    }
}

// MARK: - Swipe Overlay Label
struct SwipeOverlayLabel: View {
    enum Style {
        case like, nope, superLike
    }

    let style: Style
    let rotation: Double

    // swiftlint:disable:next large_tuple
    private var labelData: (text: String, color: Color, icon: String) {
        switch style {
        case .like:      return ("LIKE", .green, "hand.thumbsup.fill")
        case .nope:      return ("NOPE", .red, "xmark.circle.fill")
        case .superLike: return ("SUPER\nLIKE", .blue, "star.fill")
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: labelData.icon)
                .font(.system(size: 20, weight: .bold))
            Text(labelData.text)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .foregroundStyle(.white)
        .background(labelData.color.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(labelData.color, lineWidth: 3)
        )
        .rotationEffect(.degrees(rotation))
        .shadow(color: labelData.color.opacity(0.5), radius: 8, x: 0, y: 4)
        .accessibilityLabel(labelData.text)
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
