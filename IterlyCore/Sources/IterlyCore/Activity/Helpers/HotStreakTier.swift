//
//  HotStreakTier.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation

/// Visual intensity tier for a consecutive-day activity streak, used to escalate
/// the flame glyph's color as a streak grows (shared by the Activity tab and the widget).
public enum HotStreakTier: Sendable {
    case dormant
    case spark
    case warm
    case hot
    case blazing
    case inferno

    public static func tier(forStreak streak: Int) -> HotStreakTier {
        switch streak {
        case 0: .dormant
        case 1...2: .spark
        case 3...6: .warm
        case 7...13: .hot
        case 14...29: .blazing
        default: .inferno
        }
    }
}
