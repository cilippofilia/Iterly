//
//  ActivityStreakCalculator.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation

/// Pure day-summary and streak calculations shared between the app's Activity tab
/// and the IterlyWidgets extension, which cannot depend on `@MainActor`/`@Observable` state.
public enum ActivityStreakCalculator {
    public static func makeDaySummaries(
        events: [ActivityEvent],
        from start: Date,
        through end: Date,
        calendar: Calendar
    ) -> [ActivityDaySummary] {
        let eventsByDay = Dictionary(
            grouping: events,
            by: { calendar.startOfDay(for: $0.date) }
        )
        let maxCount = eventsByDay.values.map(\.count).max() ?? 0

        var currentDate = start
        var summaries: [ActivityDaySummary] = []

        while currentDate < end {
            let dayEvents = eventsByDay[currentDate, default: []]
            let projectCount = dayEvents.filter { $0.kind == .project }.count
            let taskCount = dayEvents.filter { $0.kind == .task }.count

            summaries.append(
                ActivityDaySummary(
                    date: currentDate,
                    count: dayEvents.count,
                    projectCount: projectCount,
                    taskCount: taskCount,
                    intensityLevel: intensityLevel(for: dayEvents.count, maxCount: maxCount)
                )
            )

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? end
        }

        return summaries
    }

    public static func latestStreak(in summaries: [ActivityDaySummary], calendar: Calendar) -> Int {
        let activeDays = summaries
            .filter { $0.count > 0 }
            .sorted { $0.date < $1.date }

        guard let lastActiveDate = activeDays.last?.date else { return 0 }

        var streak = 0
        var currentDate = lastActiveDate

        while let summary = summaries.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
            guard summary.count > 0 else { break }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        return streak
    }

    public static func intensityLevel(for count: Int, maxCount: Int) -> Int {
        guard count > 0, maxCount > 0 else { return 0 }

        let normalizedCount = Double(count) / Double(maxCount)
        let scaled = Int(ceil(normalizedCount * 4))
        return min(max(scaled, 1), 4)
    }

    public static func makeActivityCalendar() -> Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.firstWeekday = 2
        return calendar
    }
}
