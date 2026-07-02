//
//  HotStreakFlameView.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import SwiftUI
import WidgetKit
import IterlyCore

struct HotStreakFlameView: View {
    let streak: Int
    var flameFont: Font = .system(.title, design: .rounded, weight: .bold)
    var countFont: Font = .system(.title2, design: .rounded, weight: .bold)

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: symbolName)
                .font(flameFont)
                .foregroundStyle(flameStyle)
            Text(streak, format: .number)
                .font(countFont)
                .monospacedDigit()
            Text("day streak")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var tier: HotStreakTier {
        HotStreakTier.tier(forStreak: streak)
    }

    private var symbolName: String {
        tier == .dormant ? "flame" : "flame.fill"
    }

    private var flameStyle: AnyShapeStyle {
        switch tier {
        case .dormant:
            AnyShapeStyle(.secondary)
        case .spark:
            AnyShapeStyle(Color.orange.opacity(0.7))
        case .warm:
            AnyShapeStyle(Color.orange)
        case .hot:
            AnyShapeStyle(Color.orange.gradient)
        case .blazing:
            AnyShapeStyle(LinearGradient(colors: [.orange, .red], startPoint: .bottom, endPoint: .top))
        case .inferno:
            AnyShapeStyle(LinearGradient(colors: [.yellow, .orange, .red], startPoint: .bottom, endPoint: .top))
        }
    }
}

#Preview("Dormant", as: .systemSmall) {
    IterlyActivityWidget()
} timeline: {
    ActivityWidgetEntry(date: .now, snapshot: ActivityWidgetSnapshot(weeks: [], streak: 0, totalCount: 0, busiestDay: nil, generatedAt: .now))
}
