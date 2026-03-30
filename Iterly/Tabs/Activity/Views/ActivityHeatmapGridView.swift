//
//  ActivityHeatmapGridView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI

struct ActivityHeatmapGridView: View {
    let weeks: [[ActivityDaySummary]]
    let monthLabels: [String?]
    let selectedDay: ActivityDaySummary?
    let onSelectDay: (ActivityDaySummary) -> Void
    var isInteractive: Bool = true

    private let weekdayLabelWidth: CGFloat = 32
    private let minimumCellSize: CGFloat = 14
    private let gridSpacing: CGFloat = 4
    private let outerPadding: CGFloat = 16

    var body: some View {
        FittingHorizontalScrollView(minimumContentWidth: minimumContentWidth) { availableWidth in
            let layout = HeatmapLayoutMetrics(
                availableWidth: availableWidth - (outerPadding * 2),
                weekCount: max(weeks.count, 1),
                weekdayLabelWidth: weekdayLabelWidth,
                spacing: gridSpacing
            )

            VStack(alignment: .leading) {
                monthHeader(layout: layout)

                HStack(alignment: .top) {
                    weekdayMarkers(layout: layout)
                    weekColumns(layout: layout)
                }
            }
            .padding(outerPadding)
        }
        .frame(height: contentHeight)
    }

    private func monthHeader(layout: HeatmapLayoutMetrics) -> some View {
        HStack(alignment: .center, spacing: gridSpacing) {
            Color.clear
                .frame(width: weekdayLabelWidth, height: 20)

            ZStack(alignment: .leading) {
                ForEach(visibleMonthLabels, id: \.index) { item in
                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .offset(x: layout.xOffset(forWeekIndex: item.index))
                }
            }
            .frame(width: layout.gridWidth, height: 20, alignment: .leading)
        }
    }

    private func weekdayMarkers(layout: HeatmapLayoutMetrics) -> some View {
        VStack(alignment: .trailing, spacing: gridSpacing) {
            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: weekdayLabelWidth, height: layout.cellSize, alignment: .trailing)
                    .opacity(index.isMultiple(of: 2) ? 1 : 0)
            }
        }
        .padding(.top, 2)
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

    private var minimumContentWidth: CGFloat {
        let gridWidth = (CGFloat(max(weeks.count, 1)) * minimumCellSize)
            + (CGFloat(max(weeks.count - 1, 0)) * gridSpacing)
        return weekdayLabelWidth + gridSpacing + gridWidth + (outerPadding * 2)
    }

    private var contentHeight: CGFloat {
        let rowsHeight = (minimumCellSize * 7) + (gridSpacing * 6)
        return rowsHeight + 20 + (outerPadding * 2) + 8
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
    let weekdayLabelWidth: CGFloat
    let spacing: CGFloat

    var gridWidth: CGFloat {
        availableWidth - weekdayLabelWidth - spacing
    }

    var cellSize: CGFloat {
        let totalSpacing = CGFloat(max(weekCount - 1, 0)) * spacing
        let width = max(gridWidth - totalSpacing, 0)
        return floor(width / CGFloat(weekCount))
    }

    var cornerRadius: CGFloat {
        min(max(cellSize / 3, 4), 6)
    }

    func xOffset(forWeekIndex index: Int) -> CGFloat {
        CGFloat(index) * (cellSize + spacing)
    }
}
