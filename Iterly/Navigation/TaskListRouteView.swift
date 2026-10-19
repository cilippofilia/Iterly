//
//  TaskListRouteView.swift
//  Iterly
//

import SwiftData
import SwiftUI
import IterlyCore

/// Resolves a `TaskListRoute` against live tasks, preserving the route's order.
/// Tasks deleted since the route was created are omitted.
struct TaskListRouteView: View {
    let route: TaskListRoute

    @Query private var allTasks: [ProjectTask]

    private var tasks: [ProjectTask] {
        let tasksByID = Dictionary(allTasks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return route.taskIDs.compactMap { tasksByID[$0] }
    }

    var body: some View {
        TaskListView(title: route.title, tasks: tasks, isToned: route.isToned)
    }
}
