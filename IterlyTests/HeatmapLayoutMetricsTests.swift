//
//  HeatmapLayoutMetricsTests.swift
//  IterlyTests
//

import Foundation
import Testing
@testable import Iterly

@MainActor
struct HeatmapLayoutMetricsTests {
    @Test func wideContainerIsCappedAtMaximum() {
        let metrics = HeatmapLayoutMetrics(
            availableWidth: 1000, weekCount: 14, spacing: 4, minimumCellSize: 14, maximumCellSize: 28
        )
        #expect(metrics.cellSize == 28)
    }

    @Test func narrowContainerUsesMinimum() {
        let metrics = HeatmapLayoutMetrics(
            availableWidth: 100, weekCount: 14, spacing: 4, minimumCellSize: 14, maximumCellSize: 28
        )
        #expect(metrics.cellSize == 14)
    }

    @Test func fittedSizeInBetween() {
        let metrics = HeatmapLayoutMetrics(
            availableWidth: 400, weekCount: 14, spacing: 4, minimumCellSize: 14, maximumCellSize: 28
        )
        #expect(metrics.cellSize == floor((400 - 52) / 14))
        #expect(metrics.cellSize == 24)
    }
}
