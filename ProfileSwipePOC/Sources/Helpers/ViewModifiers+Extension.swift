//
//  ViewModifiers.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 25/08/25.
//

import SwiftUI

// MARK: - Modifiers

// MARK: - Chip Style
private struct ChipStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(.blue.opacity(0.15), in: Capsule())
            .overlay(
                Capsule().strokeBorder(.blue.opacity(0.25), lineWidth: 1)
            )
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Card style
private struct CardChrome: ViewModifier {
    let radius: CGFloat
    let shadow: CGFloat
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(radius: shadow)
            .contentShape(Rectangle()) // keeps drag target full rect
    }
}

// MARK: - Extension on View
extension View {
    // Chip Style
    func chip() -> some View { modifier(ChipStyle()) }

    // Card Style
    func cardChrome(radius: CGFloat, shadow: CGFloat) -> some View {
        modifier(CardChrome(radius: radius, shadow: shadow))
    }
}
