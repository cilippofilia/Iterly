//
//  HomeViewModel.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    func activeProjects(from projects: [Project]) -> [Project] {
        projects.filter { $0.status != .closed }
    }

    func upcomingTasks(from tasks: [ProjectTask]) -> [ProjectTask] {
        tasks
            .filter { $0.project.status != .closed }
            .filter { $0.status != .done }
            .filter { $0.status != .closed }
            .filter { $0.parentTask == nil }
            .filter { $0.dueDate != nil }
            .sorted { lhs, rhs in
                // Upcoming is due-date-first by design; ties fall back to the
                // shared display order (priority, then creation date).
                if let lhsDueDate = lhs.dueDate, let rhsDueDate = rhs.dueDate, lhsDueDate != rhsDueDate {
                    return lhsDueDate < rhsDueDate
                }
                return ProjectTask.displayOrder(lhs, rhs)
            }
    }

    func totalProjectsCount(pinned: [Project], projects: [Project]) -> Int {
        pinned.count + projects.count
    }
}
