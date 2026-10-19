//
//  HeatmapLayoutMetrics.swift
//  Iterly
//

import SwiftUI

/// Sizing for the activity heatmap: cells fit the available width, clamped between
/// a minimum (the grid scrolls horizontally) and a maximum (wide containers don't balloon).
struct HeatmapLayoutMetrics {
    let availableWidth: CGFloat
    let weekCount: Int
    let spacing: CGFloat
    let minimumCellSize: CGFloat
    let maximumCellSize: CGFloat

    var cellSize: CGFloat {
        let totalSpacing = CGFloat(max(weekCount - 1, 0)) * spacing
        let fittedSize = floor((availableWidth - totalSpacing) / CGFloat(max(weekCount, 1)))
        return min(max(fittedSize, minimumCellSize), maximumCellSize)
    }

    var cornerRadius: CGFloat {
        min(max(cellSize / 3, 4), 6)
    }

    func xOffset(forWeekIndex index: Int) -> CGFloat {
        CGFloat(index) * (cellSize + spacing)
    }
}
