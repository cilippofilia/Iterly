//
//  LocalizedText.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import Foundation

enum LocalizedText {
    static let noDueDate: String = NSLocalizedString("No due date", comment: "No due date label")

    static func tasksCount(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("tasks_count", comment: "Tasks count"),
            count
        )
    }

    static func subtasksCount(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("subtasks_count", comment: "Subtasks count"),
            count
        )
    }

    static func overdueDays(_ days: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("overdue_days", comment: "Overdue days label"),
            days
        )
    }
}
