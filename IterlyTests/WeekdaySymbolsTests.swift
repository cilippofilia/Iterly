//
//  WeekdaySymbolsTests.swift
//  IterlyTests
//

import Foundation
import Testing
@testable import Iterly

struct WeekdaySymbolsTests {
    @Test func mondayFirstCalendarStartsWithMonday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "en_GB")

        #expect(WeekdaySymbols.ordered(for: calendar).first == "Mon")
        #expect(WeekdaySymbols.ordered(for: calendar).last == "Sun")
    }

    @Test func sundayFirstCalendarStartsWithSunday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.locale = Locale(identifier: "en_US")

        #expect(WeekdaySymbols.ordered(for: calendar).first == "Sun")
    }

    @Test func alwaysSevenSymbols() {
        for firstWeekday in 1...7 {
            var calendar = Calendar(identifier: .gregorian)
            calendar.firstWeekday = firstWeekday
            calendar.locale = Locale(identifier: "en_US")

            #expect(WeekdaySymbols.ordered(for: calendar).count == 7)
        }
    }
}
