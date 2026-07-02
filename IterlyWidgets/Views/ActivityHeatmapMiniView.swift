//
//  ActivityHeatmapMiniView.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import SwiftUI
import IterlyCore

/// A fixed-column, non-interactive heatmap for the widget canvas — no scrolling, no selection,
/// unlike the app's `ActivityHeatmapGridView`, which is sized for full-screen interactive use.
///
/// The grid packs its container in both axes: cells are sized so seven weekday rows fill the
/// available height, and as many trailing week-columns as fit are drawn to fill the width. A
/// `GeometryReader` supplies the container size synchronously, which is what a widget snapshot
/// needs (there's no second layout pass to react to). Partial current weeks are padded to seven
/// rows so the grid stays square-aligned.
struct ActivityHeatmapMiniView: View {
    let weeks: [[ActivityDaySummary]]
    var cellSpacing: CGFloat = 3

    private let rowCount = 7

    var body: some View {
        GeometryReader { proxy in
            let cellSize = cellSize(forHeight: proxy.size.height)
            let columns = columnCount(forWidth: proxy.size.width, cellSize: cellSize)
            let visibleWeeks = Array(weeks.suffix(columns))

            HStack(alignment: .top, spacing: cellSpacing) {
                ForEach(visibleWeeks.indices, id: \.self) { index in
                    let column = visibleWeeks[index]
                    VStack(spacing: cellSpacing) {
                        ForEach(0 ..< rowCount, id: \.self) { row in
                            cell(for: row < column.count ? column[row] : nil)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .accessibilityLabel("Activity heatmap")
    }

    /// Cell edge that makes seven rows (plus spacing) fill the available height exactly.
    private func cellSize(forHeight height: CGFloat) -> CGFloat {
        let totalSpacing = CGFloat(rowCount - 1) * cellSpacing
        return max((height - totalSpacing) / CGFloat(rowCount), 0)
    }

    /// How many trailing week-columns fit the width at the given square cell size.
    private func columnCount(forWidth width: CGFloat, cellSize: CGFloat) -> Int {
        guard cellSize > 0 else { return 1 }
        let fitted = Int((width + cellSpacing) / (cellSize + cellSpacing))
        return max(1, min(fitted, weeks.count))
    }

    private func cell(for day: ActivityDaySummary?) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(fillStyle(for: day))
            .accessibilityHidden(true)
    }

    private func fillStyle(for day: ActivityDaySummary?) -> AnyShapeStyle {
        guard let day else {
            // Padding slot for a partial current week — occupies space but stays invisible.
            return AnyShapeStyle(.clear)
        }

        switch day.intensityLevel {
        case 0: return AnyShapeStyle(Color.secondary.opacity(0.18))
        case 1: return AnyShapeStyle(Color.green.opacity(0.45).gradient)
        case 2: return AnyShapeStyle(Color.green.opacity(0.65).gradient)
        case 3: return AnyShapeStyle(Color.green.opacity(0.82).gradient)
        default: return AnyShapeStyle(Color.green.gradient)
        }
    }
}
