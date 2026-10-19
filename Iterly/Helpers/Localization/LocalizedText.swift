//
//  LocalizedText.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import Foundation

enum LocalizedText {
    static let noDueDate: String = String(localized: "No due date", comment: "No due date label")

    static func tasksCount(_ count: Int) -> String {
        pluralized("tasks_count", comment: "Tasks count", count: count)
    }

    static func availableTasksCount(_ count: Int) -> String {
        pluralized("available_tasks_count", comment: "Available (workable) tasks count", count: count)
    }

    static func subtasksCount(_ count: Int) -> String {
        pluralized("subtasks_count", comment: "Subtasks count", count: count)
    }

    static func overdueDays(_ days: Int) -> String {
        pluralized("overdue_days", comment: "Overdue days label", count: days)
    }

    /// The pluralized noun phrase for a streak, without the number (for example "active days").
    static func activeDaysLabel(_ count: Int) -> String {
        pluralized("active_days_label", comment: "Label under the streak number", count: count)
    }

    /// Looks up a `.stringsdict` plural rule and formats it with `count`.
    private static func pluralized(_ key: String, comment: StaticString, count: Int) -> String {
        String.localizedStringWithFormat(String(localized: String.LocalizationValue(key), comment: comment), count)
    }
}
