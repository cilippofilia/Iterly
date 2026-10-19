//
//  TaskListRouteTests.swift
//  IterlyTests
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct TaskListRouteTests {
    private let context: ModelContext

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Project.self, configurations: configuration)
        context = ModelContext(container)
    }

    private func makeTasks() -> [ProjectTask] {
        let project = Project(title: "Project", projectStatus: .live)
        context.insert(project)
        return (1...3).map { index in
            let task = ProjectTask(title: "Task \(index)", project: project)
            context.insert(task)
            return task
        }
    }

    @Test func routeCapturesTaskIDsInOrder() {
        let tasks = makeTasks()
        let route = TaskListRoute(title: "Open", tasks: tasks, isToned: false)

        #expect(route.taskIDs == tasks.map(\.id))
    }

    @Test func routesWithSameTasksAreEqual() {
        let tasks = makeTasks()

        #expect(
            TaskListRoute(title: "Open", tasks: tasks, isToned: false)
                == TaskListRoute(title: "Open", tasks: tasks, isToned: false)
        )
    }

    @Test func routesWithDifferentTonesDiffer() {
        let tasks = makeTasks()

        #expect(
            TaskListRoute(title: "Open", tasks: tasks, isToned: false)
                != TaskListRoute(title: "Open", tasks: tasks, isToned: true)
        )
    }
}
