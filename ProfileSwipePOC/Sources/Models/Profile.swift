//
//  Profile.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import Foundation
import SwiftUI
import Foundation

// MARK: - Profile Model
struct Profile: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    let name: String
    let age: Int
    let bio: String?
    let imageName: String?
    let interests: [String]?
    let distance: Double
    let occupation: String?
    let education: String?
    let location: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, age, bio, imageName, interests, distance, occupation, education, location
    }
    
    var distanceText: String {
        if distance < 1 {
            return "Less than 1 km away"
        } else {
            return "\(Int(distance)) km away"
        }
    }
}
