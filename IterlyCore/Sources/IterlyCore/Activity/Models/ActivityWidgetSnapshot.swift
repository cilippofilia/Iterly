//
//  ActivityWidgetSnapshot.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation

/// Widget-ready activity payload: a trailing window of day summaries bucketed into weeks,
/// plus the derived streak/total/busiest-day stats. Rebuilt fresh on every timeline request.
public struct ActivityWidgetSnapshot: Sendable {
    public let weeks: [[ActivityDaySummary]]
    public let streak: Int
    public let hasLoggedToday: Bool
    public let totalCount: Int
    public let busiestDay: ActivityDaySummary?
    public let recentProjects: [ActivityWidgetProjectSummary]
    /// Whether `recentProjects` reflects a person's explicit widget configuration choice
    /// rather than the automatic "latest 4 updated" default.
    public let isCustomProjectSelection: Bool
    public let generatedAt: Date

    public init(
        weeks: [[ActivityDaySummary]],
        streak: Int,
        hasLoggedToday: Bool = false,
        totalCount: Int,
        busiestDay: ActivityDaySummary?,
        recentProjects: [ActivityWidgetProjectSummary] = [],
        isCustomProjectSelection: Bool = false,
        generatedAt: Date
    ) {
        self.weeks = weeks
        self.streak = streak
        self.hasLoggedToday = hasLoggedToday
        self.totalCount = totalCount
        self.busiestDay = busiestDay
        self.recentProjects = recentProjects
        self.isCustomProjectSelection = isCustomProjectSelection
        self.generatedAt = generatedAt
    }

    public static let empty = ActivityWidgetSnapshot(weeks: [], streak: 0, totalCount: 0, busiestDay: nil, generatedAt: .now)

    public static var samplePlaceholder: ActivityWidgetSnapshot {
        let calendar = ActivityStreakCalculator.makeActivityCalendar()
        let today = calendar.startOfDay(for: .now)
        let sampleCounts = [0, 2, 4, 1, 3, 0, 1, 2, 3, 4, 2, 1, 0, 3, 4, 4, 2, 1, 0, 2, 3, 4, 4, 3, 2, 1, 0, 1, 2, 3, 4, 3, 2, 1, 2]
        let maxCount = sampleCounts.max() ?? 0

        let days: [ActivityDaySummary] = sampleCounts.enumerated().map { index, count in
            let date = calendar.date(byAdding: .day, value: index - (sampleCounts.count - 1), to: today) ?? today
            return ActivityDaySummary(
                date: date,
                count: count,
                projectCount: 0,
                taskCount: count,
                intensityLevel: ActivityStreakCalculator.intensityLevel(for: count, maxCount: maxCount)
            )
        }

        let weeks = stride(from: 0, to: days.count, by: 7).map { index in
            Array(days[index ..< min(index + 7, days.count)])
        }

        return ActivityWidgetSnapshot(
            weeks: weeks,
            streak: 4,
            hasLoggedToday: true,
            totalCount: sampleCounts.reduce(0, +),
            busiestDay: days.max { $0.count < $1.count },
            recentProjects: sampleProjects(today: today, calendar: calendar),
            generatedAt: .now
        )
    }

    private static func sampleProjects(today: Date, calendar: Calendar) -> [ActivityWidgetProjectSummary] {
        func daysAgo(_ value: Int) -> Date {
            calendar.date(byAdding: .day, value: -value, to: today) ?? today
        }

        return [
            ActivityWidgetProjectSummary(id: UUID(), title: "Iterly", type: .app, status: .dev, progress: 0.7, lastUpdated: daysAgo(0)),
            ActivityWidgetProjectSummary(id: UUID(), title: "Asc CLI", type: .package, status: .beta, progress: 0.4, lastUpdated: daysAgo(1)),
            ActivityWidgetProjectSummary(id: UUID(), title: "Portfolio", type: .website, status: .live, progress: 1.0, lastUpdated: daysAgo(3)),
            ActivityWidgetProjectSummary(id: UUID(), title: "Review Skill", type: .agentSkill, status: .plan, progress: 0.15, lastUpdated: daysAgo(5)),
        ]
    }
}
