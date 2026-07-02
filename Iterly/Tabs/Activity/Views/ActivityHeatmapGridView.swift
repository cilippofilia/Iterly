//
//  ActivityHeatmapGridView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI
import IterlyCore

struct ActivityHeatmapGridView: View {
    let weeks: [[ActivityDaySummary]]
    let monthLabels: [String?]
    let selectedDay: ActivityDaySummary?
    let onSelectDay: (ActivityDaySummary) -> Void
    var isInteractive: Bool = true

    @State private var scrollableWidth: CGFloat?

    private let weekdayLabelWidth: CGFloat = 32
    private let minimumCellSize: CGFloat = 14
    private let gridSpacing: CGFloat = 4
    private let monthHeaderHeight: CGFloat = 20

    var body: some View {
        let layout = HeatmapLayoutMetrics(
            availableWidth: scrollableWidth ?? 0,
            weekCount: max(weeks.count, 1),
            spacing: gridSpacing,
            minimumCellSize: minimumCellSize
        )

        HStack(alignment: .top, spacing: gridSpacing) {
            weekdayMarkers(layout: layout)

            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: gridSpacing) {
                    monthHeader(layout: layout)
                    weekColumns(layout: layout)
                }
            }
            .defaultScrollAnchor(.trailing)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .scrollIndicators(.hidden)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { width in
                scrollableWidth = width
            }
        }
    }

    private func monthHeader(layout: HeatmapLayoutMetrics) -> some View {
        ZStack(alignment: .leading) {
            ForEach(visibleMonthLabels, id: \.index) { item in
                Text(item.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .offset(x: layout.xOffset(forWeekIndex: item.index))
            }
        }
        .frame(height: monthHeaderHeight, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func weekdayMarkers(layout: HeatmapLayoutMetrics) -> some View {
        VStack(alignment: .trailing, spacing: gridSpacing) {
            Color.clear
                .frame(width: weekdayLabelWidth, height: monthHeaderHeight)

            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: weekdayLabelWidth, height: layout.cellSize, alignment: .trailing)
                    .opacity(index.isMultiple(of: 2) ? 1 : 0)
            }
        }
    }

    private func weekColumns(layout: HeatmapLayoutMetrics) -> some View {
        HStack(alignment: .top, spacing: gridSpacing) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                VStack(spacing: gridSpacing) {
                    ForEach(week) { day in
                        if isInteractive {
                            Button {
                                onSelectDay(day)
                            } label: {
                                heatmapCell(day: day, layout: layout)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(accessibilityLabel(for: day))
                        } else {
                            heatmapCell(day: day, layout: layout)
                                .accessibilityHidden(true)
                        }
                    }
                }
            }
        }
    }

    private func heatmapCell(
        day: ActivityDaySummary,
        layout: HeatmapLayoutMetrics
    ) -> some View {
        Rectangle()
            .fill(color(for: day).gradient)
            .frame(width: layout.cellSize, height: layout.cellSize)
            .overlay {
                if isInteractive, selectedDay?.date == day.date {
                    RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                        .strokeBorder(.primary.opacity(0.45), lineWidth: 1.5)
                }
            }
            .clipShape(.rect(cornerRadius: layout.cornerRadius))
    }

    private var weekdayLabels: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }

    private var visibleMonthLabels: [VisibleMonthLabel] {
        monthLabels.enumerated().compactMap { index, label in
            guard let label else { return nil }
            return VisibleMonthLabel(index: index, label: label)
        }
    }

    private func color(for day: ActivityDaySummary) -> Color {
        switch day.intensityLevel {
        case 0: Color.secondary.opacity(0.2)
        case 1: Color.green.opacity(0.4)
        case 2: Color.green.opacity(0.6)
        case 3: Color.green.opacity(0.8)
        default: Color.green
        }
    }

    private func accessibilityLabel(for day: ActivityDaySummary) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if day.count == 0 {
            return "\(formatter.string(from: day.date)), no activity"
        }

        return "\(formatter.string(from: day.date)), \(day.count) activities"
    }
}

private struct VisibleMonthLabel {
    let index: Int
    let label: String
}

private struct HeatmapLayoutMetrics {
    let availableWidth: CGFloat
    let weekCount: Int
    let spacing: CGFloat
    let minimumCellSize: CGFloat

    var cellSize: CGFloat {
        let totalSpacing = CGFloat(max(weekCount - 1, 0)) * spacing
        let fittedSize = floor((availableWidth - totalSpacing) / CGFloat(max(weekCount, 1)))
        return max(fittedSize, minimumCellSize)
    }

    var cornerRadius: CGFloat {
        min(max(cellSize / 3, 4), 6)
    }

    func xOffset(forWeekIndex index: Int) -> CGFloat {
        CGFloat(index) * (cellSize + spacing)
    }
}
