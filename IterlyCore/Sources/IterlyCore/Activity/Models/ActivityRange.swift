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

    public var id: Self { self }

    public var title: String {
        rawValue
    }

    public var monthSpan: Int {
        switch self {
        case .threeMonths: 3
        case .sixMonths: 6
        case .twelveMonths: 12
        }
    }

    public func dateInterval(relativeTo anchorDate: Date, calendar: Calendar) -> DateInterval {
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
