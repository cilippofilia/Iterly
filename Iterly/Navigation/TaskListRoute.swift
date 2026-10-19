//
//  TaskListRoute.swift
//  Iterly
//

import Foundation
import IterlyCore

/// A plain-value navigation route to a list of tasks.
/// Tasks are carried as IDs and resolved by `TaskListRouteView`.
struct TaskListRoute: Hashable {
    let title: String
    let taskIDs: [UUID]
    let isToned: Bool

    init(title: String, tasks: [ProjectTask], isToned: Bool) {
        self.title = title
        self.taskIDs = tasks.map(\.id)
        self.isToned = isToned
    }
}
