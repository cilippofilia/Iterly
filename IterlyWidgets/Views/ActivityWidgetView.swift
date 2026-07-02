//
//  ActivityWidgetView.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import SwiftUI
import WidgetKit
import IterlyCore

struct ActivityWidgetView: View {
    let entry: ActivityWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemMedium:
            ActivityWidgetMediumView(snapshot: entry.snapshot)
        case .systemLarge:
            ActivityWidgetLargeView(snapshot: entry.snapshot)
        default:
            ActivityWidgetSmallView(snapshot: entry.snapshot)
        }
    }
}

private struct ActivityWidgetSmallView: View {
    let snapshot: ActivityWidgetSnapshot

    var body: some View {
        HotStreakFlameView(streak: snapshot.streak)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetURL(URL(string: "iterly://activity"))
    }
}

private struct ActivityWidgetMediumView: View {
    let snapshot: ActivityWidgetSnapshot

    var body: some View {
        HStack(spacing: 16) {
            ActivityHeatmapMiniView(weeks: recentWeeks)
                .frame(maxWidth: .infinity, alignment: .leading)

            HotStreakFlameView(
                streak: snapshot.streak,
                flameFont: .system(.title2, design: .rounded, weight: .bold),
                countFont: .system(.title3, design: .rounded, weight: .bold)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "iterly://activity"))
    }

    private var recentWeeks: [[ActivityDaySummary]] {
        Array(snapshot.weeks.suffix(11))
    }
}

private struct ActivityWidgetLargeView: View {
    let snapshot: ActivityWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ActivityHeatmapMiniView(weeks: recentWeeks)
                .frame(maxWidth: .infinity)

            HStack {
                statColumn(title: "Streak", value: snapshot.streak)
                Spacer()
                statColumn(title: "Total", value: snapshot.totalCount)
                Spacer()
                statColumn(title: "Busiest", value: snapshot.busiestDay?.count ?? 0)
            }

            HStack {
                HotStreakFlameView(
                    streak: snapshot.streak,
                    flameFont: .system(.title3, design: .rounded, weight: .bold),
                    countFont: .system(.body, design: .rounded, weight: .bold)
                )
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "iterly://activity"))
    }

    private var recentWeeks: [[ActivityDaySummary]] {
        Array(snapshot.weeks.suffix(20))
    }

    private func statColumn(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value, format: .number)
                .font(.headline)
                .monospacedDigit()
        }
    }
}

#Preview("Medium", as: .systemMedium) {
    IterlyActivityWidget()
} timeline: {
    ActivityWidgetEntry(date: .now, snapshot: .samplePlaceholder)
}

#Preview("Large", as: .systemLarge) {
    IterlyActivityWidget()
} timeline: {
    ActivityWidgetEntry(date: .now, snapshot: .samplePlaceholder)
}
