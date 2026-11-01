//
//  ActivityOverviewViewModel.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation
import IterlyCore

@MainActor
@Observable
final class ActivityOverviewViewModel {
    var selectedRange: ActivityRange = .threeMonths
    private(set) var availableRanges = ActivityOverviewViewModel.compactRanges
    var weeks: [[ActivityDaySummary]] = []
    var monthLabels: [String?] = []
    var summary: ActivityOverviewSummary = .empty
    var selectedDay: ActivityDaySummary?
    var selectedDayEvents: [ActivityEvent] = []

    /// Ranges offered in compact width, where a 3-month grid fills the card.
    private static let compactRanges: [ActivityRange] = [.threeMonths, .sixMonths, .twelveMonths]
    /// Ranges offered in regular width, where a 3-month grid would leave most of the card empty.
    private static let regularRanges: [ActivityRange] = [.sixMonths, .twelveMonths, .allTime]

    private let provider: any ActivityDataProviding
    private let nowProvider: () -> Date
    private var calendar: Calendar
    private var eventsByDay: [Date: [ActivityEvent]] = [:]

    init(
        provider: (any ActivityDataProviding)? = nil,
        calendar: Calendar = ActivityOverviewViewModel.makeActivityOverviewCalendar(),
        nowProvider: @escaping () -> Date = { .now }
    ) {
        self.provider = provider ?? ActivityDataProvider()
        self.calendar = calendar
        self.nowProvider = nowProvider
    }

    func reload(projects: [Project], tasks: [ProjectTask]) {
        let now = nowProvider()
        var interval = selectedRange.dateInterval(relativeTo: now, calendar: calendar)
        let events = provider.events(
            for: selectedRange,
            now: now,
            projects: projects,
            tasks: tasks,
            calendar: calendar
        )

        if selectedRange == .allTime {
            // Start at the earliest activity, but never show less than the 12-month grid.
            let twelveMonthStart = ActivityRange.twelveMonths.dateInterval(relativeTo: now, calendar: calendar).start
            let earliestEvent = events.map(\.date).min() ?? twelveMonthStart
            interval = DateInterval(start: min(earliestEvent, twelveMonthStart), end: now)
        }

        eventsByDay = Dictionary(
            grouping: events,
            by: { calendar.startOfDay(for: $0.date) }
        )

        let displayStart = calendar.dateInterval(of: .weekOfYear, for: interval.start)?.start ?? interval.start
        let displayEnd = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: interval.end)
        ) ?? interval.end
        let daySummaries = makeDaySummaries(from: displayStart, through: displayEnd)

        weeks = stride(from: 0, to: daySummaries.count, by: 7).map { index in
            Array(daySummaries[index ..< min(index + 7, daySummaries.count)])
        }
        monthLabels = makeMonthLabels(for: weeks, interval: interval)
        summary = makeSummary(from: daySummaries, interval: interval)
        syncSelection(with: daySummaries)
    }

    func updateAvailableRanges(isRegularWidth: Bool) {
        availableRanges = isRegularWidth ? Self.regularRanges : Self.compactRanges
        if !availableRanges.contains(selectedRange), let firstRange = availableRanges.first {
            selectedRange = firstRange
        }
    }

    func selectDay(_ day: ActivityDaySummary) {
        selectedDay = day
        selectedDayEvents = eventsByDay[calendar.startOfDay(for: day.date), default: []]
            .sorted { lhs, rhs in
                if lhs.kind != rhs.kind {
                    return lhs.kind.rawValue < rhs.kind.rawValue
                }
                return lhs.title < rhs.title
            }
    }

    private func makeDaySummaries(from start: Date, through end: Date) -> [ActivityDaySummary] {
        let events = eventsByDay.values.flatMap { $0 }
        return ActivityStreakCalculator.makeDaySummaries(events: events, from: start, through: end, calendar: calendar)
    }

    private func makeMonthLabels(
        for weeks: [[ActivityDaySummary]],
        interval: DateInterval
    ) -> [String?] {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        // All time can span several years, so January and the first column carry the year.
        let yearFormatter = DateFormatter()
        yearFormatter.calendar = calendar
        yearFormatter.setLocalizedDateFormatFromTemplate("MMM yy")
        let showsYear = selectedRange == .allTime

        return weeks.enumerated().map { index, week in
            guard let firstDay = week.first?.date else { return nil }
            let monthStart = week.first(where: { day in
                calendar.component(.day, from: day.date) == 1 && interval.contains(day.date)
            })?.date

            if let monthStart {
                let isJanuary = calendar.component(.month, from: monthStart) == 1
                return (showsYear && isJanuary ? yearFormatter : formatter).string(from: monthStart)
            }

            if index == 0 {
                return (showsYear ? yearFormatter : formatter).string(from: firstDay)
            }

            return nil
        }
    }

    private func makeSummary(
        from summaries: [ActivityDaySummary],
        interval: DateInterval
    ) -> ActivityOverviewSummary {
        let visibleSummaries = summaries.filter { interval.contains($0.date) }
        let totalCount = visibleSummaries.reduce(0) { $0 + $1.count }
        let busiestDay = visibleSummaries.max { lhs, rhs in
            if lhs.count != rhs.count {
                return lhs.count < rhs.count
            }

            return lhs.date < rhs.date
        }
        let streak = ActivityStreakCalculator.latestStreak(in: visibleSummaries, calendar: calendar)

        return ActivityOverviewSummary(
            totalCount: totalCount,
            streak: streak,
            busiestDay: busiestDay
        )
    }

    private func syncSelection(with summaries: [ActivityDaySummary]) {
        if let selectedDay,
           let matchingDay = summaries.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDay.date) }) {
            selectDay(matchingDay)
            return
        }

        if let mostRecentActiveDay = summaries.last(where: { $0.count > 0 }) {
            selectDay(mostRecentActiveDay)
            return
        }

        if let latestDay = summaries.last {
            selectDay(latestDay)
        }
    }

}

private extension ActivityOverviewViewModel {
    nonisolated static func makeActivityOverviewCalendar() -> Calendar {
        ActivityStreakCalculator.makeActivityCalendar()
    }
}
