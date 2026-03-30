//
//  ActivityRange.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

enum ActivityRange: String, CaseIterable, Identifiable {
    case threeMonths = "3m"
    case sixMonths = "6m"
    case twelveMonths = "12m"

    var id: Self { self }

    var title: String {
        rawValue
    }

    var monthSpan: Int {
        switch self {
        case .threeMonths: 3
        case .sixMonths: 6
        case .twelveMonths: 12
        }
    }

    func dateInterval(relativeTo anchorDate: Date, calendar: Calendar) -> DateInterval {
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
