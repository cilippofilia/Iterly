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
        VStack(alignment: .leading, spacing: 10) {
            ActivityWidgetHeaderView(streak: snapshot.streak)
            ActivityHeatmapMiniView(weeks: snapshot.weeks)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .widgetURL(URL(string: "iterly://activity"))
    }
}

private struct ActivityWidgetLargeView: View {
    let snapshot: ActivityWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ActivityWidgetHeaderView(streak: snapshot.streak)

            ActivityHeatmapMiniView(weeks: snapshot.weeks)

            ActivityWidgetStatsRowView(
                total: snapshot.totalCount,
                activeDays: activeDays,
                busiest: snapshot.busiestDay?.count ?? 0
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .widgetURL(URL(string: "iterly://activity"))
    }

    private var activeDays: Int {
        snapshot.weeks.reduce(0) { partial, week in
            partial + week.count { $0.count > 0 }
        }
    }
}

/// A wordmark plus the streak pill, shared by the medium and large widgets.
private struct ActivityWidgetHeaderView: View {
    let streak: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Activity")
                .font(.system(.headline, design: .rounded, weight: .bold))
            Spacer()
            HotStreakChip(streak: streak)
        }
    }
}

private struct ActivityWidgetStatsRowView: View {
    let total: Int
    let activeDays: Int
    let busiest: Int

    var body: some View {
        HStack(alignment: .top) {
            ActivityWidgetStatView(title: "Total", value: total)
            ActivityWidgetStatView(title: "Active days", value: activeDays)
            ActivityWidgetStatView(title: "Busiest day", value: busiest)
        }
    }
}

private struct ActivityWidgetStatView: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value, format: .number)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
