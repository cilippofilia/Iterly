//
//  ActivityOverviewViewModelTests.swift
//  IterlyTests
//

import Foundation
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct ActivityOverviewViewModelTests {
    @Test func regularWidthDropsThreeMonthsAndFallsBackToSixMonths() {
        let viewModel = ActivityOverviewViewModel()

        viewModel.updateAvailableRanges(isRegularWidth: true)

        #expect(viewModel.availableRanges == [.sixMonths, .twelveMonths, .allTime])
        #expect(viewModel.selectedRange == .sixMonths)
    }

    @Test func compactWidthFallsBackFromAllTime() {
        let viewModel = ActivityOverviewViewModel()
        viewModel.updateAvailableRanges(isRegularWidth: true)
        viewModel.selectedRange = .allTime

        viewModel.updateAvailableRanges(isRegularWidth: false)

        #expect(viewModel.selectedRange == .threeMonths)
    }

    @Test func allTimeSpansAtLeastTwelveMonths() {
        let viewModel = ActivityOverviewViewModel()
        viewModel.selectedRange = .twelveMonths
        viewModel.reload(projects: [], tasks: [])
        let twelveMonthWeeks = viewModel.weeks.count

        viewModel.selectedRange = .allTime
        viewModel.reload(projects: [], tasks: [])

        #expect(viewModel.weeks.count == twelveMonthWeeks)
    }

    @Test func allTimeStartsAtActivityOlderThanTwelveMonths() throws {
        let calendar = ActivityStreakCalculator.makeActivityCalendar()
        let now = Date.now
        let oldDate = try #require(calendar.date(byAdding: .year, value: -2, to: now))
        let provider = StubActivityProvider(events: [
            ActivityEvent(date: oldDate, kind: .project, title: "Old", context: "Created", projectType: nil)
        ])
        let viewModel = ActivityOverviewViewModel(provider: provider, calendar: calendar, nowProvider: { now })
        viewModel.selectedRange = .allTime

        viewModel.reload(projects: [], tasks: [])

        let firstDay = try #require(viewModel.weeks.first?.first?.date)
        #expect(calendar.isDate(firstDay, equalTo: oldDate, toGranularity: .weekOfYear))
        #expect(viewModel.monthLabels.first??.contains(firstDay.formatted(.dateTime.year(.twoDigits))) == true)
    }
}

private struct StubActivityProvider: ActivityDataProviding {
    let events: [ActivityEvent]

    func events(
        for range: ActivityRange,
        now: Date,
        projects: [Project],
        tasks: [ProjectTask],
        calendar: Calendar
    ) -> [ActivityEvent] {
        events
    }
}
