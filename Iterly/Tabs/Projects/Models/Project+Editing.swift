//
//  Project+Editing.swift
//  Iterly
//

import Foundation
import IterlyCore

extension Project {
    /// Sets the status and touches the project.
    /// - Returns: `true` if the status changed; `false` (and no side effects) if it was already equal.
    @discardableResult
    func updateStatus(_ status: ProjectStatus) -> Bool {
        guard self.status != status else { return false }
        self.status = status
        touch()
        return true
    }

    func updatePriority(_ priority: ProjectPriority) {
        self.priority = priority
        touch()
    }
}
