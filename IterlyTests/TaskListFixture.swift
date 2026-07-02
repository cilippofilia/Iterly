//
//  TaskListFixture.swift
//  IterlyTests
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import SwiftData
import IterlyCore
@testable import Iterly

/// An in-memory SwiftData stack with a single project, used to build tasks for sorting tests.
@MainActor
struct TaskListFixture {
    let context: ModelContext
    let project: Project

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Project.self, configurations: configuration)
        context = ModelContext(container)
        project = Project(title: "Fixture Project")
        context.insert(project)
    }

    func makeTask(
        _ title: String,
        priority: TaskPriority = .notSet,
        dueDate: Date? = nil,
        creationDate: Date,
        status: TaskStatus = .notStarted
    ) -> ProjectTask {
        let task = ProjectTask(
            title: title,
            status: status,
            dueDate: dueDate,
            priority: priority,
            creationDate: creationDate,
            project: project
        )
        context.insert(task)
        return task
    }
}
