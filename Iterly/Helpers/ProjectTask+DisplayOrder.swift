//
//  ProjectTask+DisplayOrder.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation

extension ProjectTask {
    /// The shared ordering for every task and subtask list in the app:
    /// priority first (high before low), then earliest due date with undated
    /// tasks last, then creation date as a stable tiebreaker.
    static func displayOrder(_ lhs: ProjectTask, _ rhs: ProjectTask) -> Bool {
        if lhs.priority.sortRank != rhs.priority.sortRank {
            return lhs.priority.sortRank < rhs.priority.sortRank
        }

        switch (lhs.dueDate, rhs.dueDate) {
        case let (lhsDueDate?, rhsDueDate?) where lhsDueDate != rhsDueDate:
            return lhsDueDate < rhsDueDate
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        default:
            return lhs.creationDate < rhs.creationDate
        }
    }
}

extension [ProjectTask] {
    /// The tasks sorted by the shared display order; see `ProjectTask.displayOrder(_:_:)`.
    func sortedForDisplay() -> [ProjectTask] {
        sorted(by: ProjectTask.displayOrder)
    }
}
