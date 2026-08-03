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
            ActivityWidgetSmallView(date: entry.date, snapshot: entry.snapshot)
        }
    }
}

private struct ActivityWidgetSmallView: View {
    let date: Date
    let snapshot: ActivityWidgetSnapshot

    private var isActiveStreak: Bool { snapshot.streak > 0 }

    /// 0 when the streak is fully lit (already logged today, or freshly carried over
    /// from yesterday), ramping up in four six-hourly steps if nothing's logged yet —
    /// the flame "burning down" through the day. Caps below full cold so an active-but-
    /// unlogged streak always reads as still-alive; only a truly lapsed streak (1) goes
    /// fully gray.
    private var coldness: Double {
        guard isActiveStreak else { return 1 }
        guard !snapshot.hasLoggedToday else { return 0 }

        let hour = Calendar.autoupdatingCurrent.component(.hour, from: date)
        let sixHourStep = hour / 6
        return Double(sixHourStep) / 4
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: isActiveStreak ? "flame.fill" : "flame")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.5 * (1 - coldness)), radius: 9)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

            Text(snapshot.streak, format: .number)
                .font(.system(.largeTitle, design: .monospaced, weight: .black))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 1)

            Text("day streak")
                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            ActivityWidgetSmallBackground(coldness: coldness)
        }
        .widgetURL(URL(string: "iterly://activity"))
    }
}

/// The small widget's backdrop: a rich amber-to-deep-orange fire gradient that cools
/// towards a muted slate gray as `coldness` climbs from 0 (fully lit) to 1 (lapsed, or
/// simply unattended for the whole day).
private struct ActivityWidgetSmallBackground: View {
    let coldness: Double

    private static let hotStops: [(Double, Double, Double)] = [
        (1.0, 0.80, 0.30),
        (1.0, 0.55, 0.15),
        (0.96, 0.37, 0.09),
    ]

    private static let coldStops: [(Double, Double, Double)] = [
        (0.55, 0.55, 0.55),
        (0.4, 0.4, 0.4),
        (0.28, 0.28, 0.28),
    ]

    private var gradientColors: [Color] {
        zip(Self.hotStops, Self.coldStops).map { hot, cold in
            Color(
                red: lerp(hot.0, cold.0, coldness),
                green: lerp(hot.1, cold.1, coldness),
                blue: lerp(hot.2, cold.2, coldness)
            )
        }
    }

    private func lerp(_ from: Double, _ to: Double, _ fraction: Double) -> Double {
        from + (to - from) * fraction
    }

    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                RadialGradient(
                    colors: [.white.opacity(0.35 * (1 - coldness)), .clear],
                    center: UnitPoint(x: 0.5, y: 0.28),
                    startRadius: 2,
                    endRadius: 100
                )
            }
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
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "iterly://activity"))
    }
}

private struct ActivityWidgetLargeView: View {
    let snapshot: ActivityWidgetSnapshot

    /// Matches the medium widget's cell density; also fixes the heatmap band height.
    private let heatmapCellSize: CGFloat = 13
    private let heatmapCellSpacing: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ActivityWidgetHeaderView(streak: snapshot.streak)

            ActivityHeatmapMiniView(
                weeks: snapshot.weeks,
                cellSpacing: heatmapCellSpacing,
                maxCellSize: heatmapCellSize
            )
            .frame(maxHeight: heatmapBandHeight)

            ActivityWidgetStatsRowView(
                total: snapshot.totalCount,
                activeDays: activeDays,
                busiest: snapshot.busiestDay?.count ?? 0
            )

            if snapshot.recentProjects.isEmpty {
                Spacer(minLength: 0)
            } else {
                Divider()
                ActivityWidgetProjectsSectionView(
                    title: snapshot.isCustomProjectSelection ? "Your projects" : "Recently worked on",
                    projects: snapshot.recentProjects
                )
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "iterly://activity"))
    }

    private var heatmapBandHeight: CGFloat {
        heatmapCellSize * 7 + heatmapCellSpacing * 6
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
                .font(.system(.headline, design: .rounded, weight: .bold))
                .monospacedDigit()
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityWidgetProjectsSectionView: View {
    let title: LocalizedStringKey
    let projects: [ActivityWidgetProjectSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)

            ForEach(projects) { project in
                ActivityWidgetProjectRowView(project: project)
            }
        }
    }
}

private struct ActivityWidgetProjectRowView: View {
    let project: ActivityWidgetProjectSummary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: project.type.systemImage)
                .font(.footnote)
                .foregroundStyle(project.status.backgroundColor)
                .frame(width: 18)

            Text(project.title)
                .font(.subheadline)
                .lineLimit(1)

            Spacer(minLength: 8)

            ProgressView(value: clampedProgress)
                .progressViewStyle(.linear)
                .tint(project.status.backgroundColor)
                .frame(width: 44)

            Text(clampedProgress, format: .percent.precision(.fractionLength(0)))
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.title), \(project.status.title), \(Int(clampedProgress * 100)) percent done")
    }

    private var clampedProgress: Double {
        min(max(project.progress, 0), 1)
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

#Preview("Small – Logged Today", as: .systemSmall) {
    IterlyActivityWidget()
} timeline: {
    ActivityWidgetEntry(
        date: .now,
        snapshot: ActivityWidgetSnapshot(
            weeks: [], streak: 6, hasLoggedToday: true, totalCount: 30, busiestDay: nil, generatedAt: .now
        )
    )
}

/// Same streak, nothing logged yet today — scrub the canvas timeline bar to watch the
/// flame cool from full blaze to nearly out across the four six-hourly steps.
#Preview("Small – Cooling Through the Day", as: .systemSmall) {
    IterlyActivityWidget()
} timeline: {
    let calendar = Calendar.current
    let unloggedSnapshot = ActivityWidgetSnapshot(
        weeks: [], streak: 6, hasLoggedToday: false, totalCount: 30, busiestDay: nil, generatedAt: .now
    )

    for hour in [1, 7, 13, 19] {
        ActivityWidgetEntry(
            date: calendar.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now,
            snapshot: unloggedSnapshot
        )
    }
}
