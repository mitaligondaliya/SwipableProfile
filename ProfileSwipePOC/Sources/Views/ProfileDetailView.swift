//
//  ProfileDetailView.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

// MARK: - Profile Detail Screen
import SwiftUI

struct ProfileDetailView: View {
    let profile: Profile
    @Binding var selectedProfile: Profile?   // renamed for clarity

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Profile Image
                    if let imageName = profile.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .clipped()
                    } else {
                        Image("placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .clipped()
                    }

                    // Profile Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("\(profile.name), \(profile.age)")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                            Text("\(profile.distance, specifier: "%.1f") km away")
                                .foregroundColor(.gray)
                        }

                        if let occupation = profile.occupation {
                            Text("💼 \(occupation)")
                                .font(.subheadline)
                        }

                        if let education = profile.education {
                            Text("🎓 \(education)")
                                .font(.subheadline)
                        }

                        if let bio = profile.bio {
                            Text(bio)
                                .font(.body)
                                .padding(.top, 4)
                        }

                        if let interests = profile.interests, !interests.isEmpty {
                            Text("Interests")
                                .font(.headline)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                                ForEach(interests, id: \.self) { interest in
                                    Text(interest)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        selectedProfile = nil
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileDetailView(
        profile: Profile(
            name: "Mitalee",
            age: 30,
            bio: "iOS Engineer | Loves SwiftUI, Combine & Travel ✈️",
            imageName: "placeholder",
            interests: ["Coding", "Travel", "Cooking"],
            distance: 5.2,
            occupation: "Software Engineer",
            education: "M.Sc Computer Science",
            location: "India"
        ),
        selectedProfile: .constant(nil)
    )
}
