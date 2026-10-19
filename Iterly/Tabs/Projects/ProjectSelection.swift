//
//  ProjectSelection.swift
//  Iterly
//

import IterlyCore

/// Keeps the split-view selection in sync with the stored projects.
enum ProjectSelection {
    /// Returns `selected` only if a project with the same `id` is still in `projects`.
    static func validated(_ selected: Project?, in projects: [Project]) -> Project? {
        guard let selected else { return nil }
        return projects.contains { $0.id == selected.id } ? selected : nil
    }
}
