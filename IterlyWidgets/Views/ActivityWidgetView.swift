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

    private var isActiveStreak: Bool { snapshot.streak > 0 }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: isActiveStreak ? "flame.fill" : "flame")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(isActiveStreak ? 0.5 : 0), radius: 9)
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
            ActivityWidgetSmallBackground(isActiveStreak: isActiveStreak)
        }
        .widgetURL(URL(string: "iterly://activity"))
    }
}

/// The small widget's backdrop: a rich amber-to-deep-orange fire gradient with a soft
/// highlight behind the flame while the streak is active, or a muted slate gradient
/// once it's lapsed.
private struct ActivityWidgetSmallBackground: View {
    let isActiveStreak: Bool

    var body: some View {
        if isActiveStreak {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.80, blue: 0.30),
                    Color(red: 1.0, green: 0.55, blue: 0.15),
                    Color(red: 0.96, green: 0.37, blue: 0.09),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                RadialGradient(
                    colors: [.white.opacity(0.35), .clear],
                    center: UnitPoint(x: 0.5, y: 0.28),
                    startRadius: 2,
                    endRadius: 100
                )
            }
        } else {
            LinearGradient(
                colors: [
                    Color(white: 0.55),
                    Color(white: 0.4),
                    Color(white: 0.28),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
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
                ActivityWidgetProjectsSectionView(projects: snapshot.recentProjects)
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
    let projects: [ActivityWidgetProjectSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Recently worked on")
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
