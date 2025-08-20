//
//  MatchResult.swift
//  ProfileSwipePOC
//
//  Created by Mitali Gondaliya on 20/08/25.
//

import Foundation

// MARK: - Match Result
enum MatchResult {
    case like
    case dislike
    case superLike
    case match
}

// MARK: - Swipe Direction
enum SwipeDirection {
    case left
    case right
    case up
    
    var matchResult: MatchResult {
        switch self {
        case .left:
            return .dislike
        case .right:
            return .like
        case .up:
            return .superLike
        }
    }
}
