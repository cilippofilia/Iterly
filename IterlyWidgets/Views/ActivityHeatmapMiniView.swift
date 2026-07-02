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
struct ActivityHeatmapMiniView: View {
    let weeks: [[ActivityDaySummary]]
    var cellSpacing: CGFloat = 3

    var body: some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(weeks.indices, id: \.self) { index in
                VStack(spacing: cellSpacing) {
                    ForEach(weeks[index]) { day in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(color(for: day))
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .accessibilityLabel("Activity heatmap")
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
}
