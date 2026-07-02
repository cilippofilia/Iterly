//
//  ActivityOverviewSummary.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

public struct ActivityOverviewSummary: Sendable {
    public let totalCount: Int
    public let streak: Int
    public let busiestDay: ActivityDaySummary?

    public init(totalCount: Int, streak: Int, busiestDay: ActivityDaySummary?) {
        self.totalCount = totalCount
        self.streak = streak
        self.busiestDay = busiestDay
    }

    public static let empty = ActivityOverviewSummary(totalCount: 0, streak: 0, busiestDay: nil)
}
