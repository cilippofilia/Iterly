//
//  ProjectTask+Editing.swift
//  Iterly
//

import Foundation
import IterlyCore

extension ProjectTask {
    /// Sets the status and touches the task and its project.
    /// - Returns: `true` if the status changed; `false` (and no side effects) if it was already equal.
    @discardableResult
    func updateStatus(_ status: TaskStatus) -> Bool {
        guard self.status != status else { return false }
        self.status = status
        touchWithProject()
        return true
    }

    func updatePriority(_ priority: TaskPriority) {
        self.priority = priority
        touchWithProject()
    }

    func updateDueDate(_ date: Date) {
        dueDate = date
        touchWithProject()
    }

    private func touchWithProject() {
        touch()
        project?.touch()
    }
}
