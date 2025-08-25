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
    case swipeLeft
    case swipeRight
    case swipeUp

    var matchResult: MatchResult {
        switch self {
        case .swipeLeft:
            return .dislike
        case .swipeRight:
            return .like
        case .swipeUp:
            return .superLike
        }
    }
}
