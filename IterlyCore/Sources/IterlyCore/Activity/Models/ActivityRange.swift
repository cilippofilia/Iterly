//
//  ActivityRange.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

public enum ActivityRange: String, CaseIterable, Identifiable, Sendable {
    case threeMonths = "3 months"
    case sixMonths = "6 months"
    case twelveMonths = "12 months"
    case allTime = "All time"

    public var id: Self { self }

    public var title: String {
        rawValue
    }

    /// `nil` for `.allTime`, which has no fixed span.
    public var monthSpan: Int? {
        switch self {
        case .threeMonths: 3
        case .sixMonths: 6
        case .twelveMonths: 12
        case .allTime: nil
        }
    }

    public func dateInterval(relativeTo anchorDate: Date, calendar: Calendar) -> DateInterval {
        guard let monthSpan else {
            return DateInterval(start: .distantPast, end: anchorDate)
        }

        let startOfToday = calendar.startOfDay(for: anchorDate)
        let monthAnchor = calendar.date(
            byAdding: .month,
            value: -(monthSpan - 1),
            to: startOfToday
        ) ?? startOfToday
        let monthComponents = calendar.dateComponents([.year, .month], from: monthAnchor)
        let startOfMonth = calendar.date(from: monthComponents) ?? monthAnchor

        return DateInterval(start: startOfMonth, end: anchorDate)
    }
}
