//
//  ActivityReloadKey.swift
//  Iterly
//

import Foundation
import IterlyCore

/// Cheap change-detection key for the activity heatmap inputs.
///
/// Hashes only the fields the activity data depends on, avoiding the O(n)
/// string building that used to run on every view body evaluation.
enum ActivityReloadKey {
    static func make(range: ActivityRange, projects: [Project], tasks: [ProjectTask]) -> Int {
        var hasher = Hasher()
        hasher.combine(range.rawValue)
        for project in projects {
            hasher.combine(project.id)
            hasher.combine(project.lastUpdated)
        }
        for task in tasks {
            hasher.combine(task.id)
            hasher.combine(task.creationDate)
            hasher.combine(task.lastUpdated)
        }
        return hasher.finalize()
    }
}
