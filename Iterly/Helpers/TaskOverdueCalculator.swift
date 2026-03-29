//
//  TaskOverdueCalculator.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import Foundation

enum TaskOverdueCalculator {
    static func overdueDays(dueDate: Date?, now: Date = .now) -> Int? {
        guard let dueDate else { return nil }
        let calendar = Calendar.autoupdatingCurrent
        let dueDay = calendar.startOfDay(for: dueDate)
        let today = calendar.startOfDay(for: now)
        guard dueDay < today else { return nil }
        let days = calendar.dateComponents([.day], from: dueDay, to: today).day ?? 0
        return max(days, 1)
    }
}
