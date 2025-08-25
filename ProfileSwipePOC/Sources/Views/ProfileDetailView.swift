//
//  ProfileDetailView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import SwiftUI

// MARK: - Profile Detail Screen
struct ProfileDetailView: View {
    let profile: Profile
    @Binding var selectedProfile: Profile?

    private var personImageName: String { profile.imageName ?? "placeholder" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    person

                    info
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", role: .cancel) { selectedProfile = nil }
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // MARK: - Sections

    private var person: some View {
        Image(personImageName)
            .resizable()
            .scaledToFill()
            .frame(height: 400)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.35)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            .accessibilityLabel(Text("\(profile.name)'s photo"))
            .accessibilityHidden(false)
    }

    @ViewBuilder
    private var info: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(profile.name), \(profile.age)")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer()

                Text("\(profile.distance, specifier: "%.1f") km away")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .accessibilityLabel(Text("\(profile.distance, specifier: "%.1f") kilometers away"))
            }

            optionalRow(icon: "💼", text: profile.occupation)
            optionalRow(icon: "🎓", text: profile.education)
            optionalText(profile.bio)

            if let interests = profile.interests, !interests.isEmpty {
                section("Interests") {
                    InterestsChips(interests: interests)
                }
            }
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    private func optionalRow(icon: String, text: String?) -> some View {
        if let text, !text.isEmpty {
            InfoRow(icon: icon, text: text)
        }
    }

    @ViewBuilder
    private func optionalText(_ text: String?) -> some View {
        if let text, !text.isEmpty {
            Text(text)
                .font(.body)
                .padding(.top, 4)
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(.top, 6)
    }
}

// MARK: - Reusable Subviews

private struct InfoRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
            Text(text)
                .font(.subheadline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(text)")
    }
}

private struct InterestsChips: View {
    let interests: [String]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 10)], spacing: 10) {
            ForEach(interests, id: \.self) { interest in
                Text(interest)
                    .chip() // uses ViewModifier
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Group {
        ProfileDetailView(
            profile: Profile(
                name: "Mitalee",
                age: 30,
                bio: "iOS Engineer | Loves SwiftUI, Combine & Travel ✈️",
                imageName: "placeholder",
                interests: ["Coding", "Travel", "Cooking", "Hiking", "Photography", "Coffee"],
                distance: 5.2,
                occupation: "Software Engineer",
                education: "M.Sc Computer Science",
                location: "India"
            ),
            selectedProfile: .constant(nil)
        )

        ProfileDetailView(
            profile: Profile(
                name: "Aria",
                age: 27,
                bio: nil,
                imageName: nil,
                interests: [],
                distance: 12.7,
                occupation: nil,
                education: nil,
                location: "India"
            ),
            selectedProfile: .constant(nil)
        )
        .environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}
