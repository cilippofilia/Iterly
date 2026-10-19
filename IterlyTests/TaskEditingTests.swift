//
//  TaskEditingTests.swift
//  IterlyTests
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct TaskEditingTests {
    private let context: ModelContext
    private let oldDate = Date(timeIntervalSinceReferenceDate: 1_000)

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, ProjectTask.self, TaskAttachment.self, ProjectRelease.self, ProjectLink.self,
            configurations: configuration
        )
        context = ModelContext(container)
    }

    private func makeTask(status: TaskStatus = .notStarted) -> ProjectTask {
        let project = Project(title: "P")
        context.insert(project)
        let task = ProjectTask(title: "T", status: status, project: project)
        context.insert(task)
        project.lastUpdated = oldDate
        task.lastUpdated = oldDate
        return task
    }

    @Test func updateStatusReportsChangeAndTouches() throws {
        let task = makeTask(status: .notStarted)

        let changed = task.updateStatus(.done)

        #expect(changed == true)
        #expect(task.status == .done)
        #expect(try #require(task.lastUpdated) > oldDate)
        #expect(try #require(task.project).lastUpdated > oldDate)
    }

    @Test func updateStatusToSameValueIsNoOp() throws {
        let task = makeTask(status: .notStarted)

        let changed = task.updateStatus(.notStarted)

        #expect(changed == false)
        #expect(task.lastUpdated == oldDate)
        #expect(try #require(task.project).lastUpdated == oldDate)
    }

    @Test func projectUpdateStatusReportsChange() {
        let project = Project(title: "P", projectStatus: .plan)
        context.insert(project)
        project.lastUpdated = oldDate

        #expect(project.updateStatus(.live) == true)
        #expect(project.status == .live)
        #expect(project.lastUpdated > oldDate)

        project.lastUpdated = oldDate
        #expect(project.updateStatus(.live) == false)
        #expect(project.lastUpdated == oldDate)
    }
}
