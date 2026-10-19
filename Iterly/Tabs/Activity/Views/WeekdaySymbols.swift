//
//  WeekdaySymbols.swift
//  Iterly
//

import Foundation

/// Localized short weekday names ordered from the calendar's first weekday.
enum WeekdaySymbols {
    static func ordered(for calendar: Calendar) -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        guard symbols.isEmpty == false else { return [] }

        let offset = (calendar.firstWeekday - 1) % symbols.count
        return Array(symbols[offset...] + symbols[..<offset])
    }
}
