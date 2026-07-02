//
//  HotStreakFlameView.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import SwiftUI
import WidgetKit
import IterlyCore

/// The escalating flame glyph on its own, styled by the streak's `HotStreakTier`.
/// Used by the compact `HotStreakChip` in the medium and large widget headers.
struct HotStreakFlameGlyph: View {
    let streak: Int
    var font: Font = .system(.title, design: .rounded, weight: .bold)

    var body: some View {
        Image(systemName: symbolName)
            .font(font)
            .foregroundStyle(flameStyle)
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

/// Compact horizontal streak pill for the medium and large widget headers.
struct HotStreakChip: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 5) {
            HotStreakFlameGlyph(streak: streak, font: .system(.subheadline, design: .rounded, weight: .bold))

            Text(streak, format: .number)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .monospacedDigit()

            Text("day streak")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .padding(.vertical, 5)
        .background(.quaternary, in: .capsule)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(streak) day streak")
    }
}

#Preview("Dormant", as: .systemSmall) {
    IterlyActivityWidget()
} timeline: {
    ActivityWidgetEntry(date: .now, snapshot: ActivityWidgetSnapshot(weeks: [], streak: 0, totalCount: 0, busiestDay: nil, generatedAt: .now))
}
