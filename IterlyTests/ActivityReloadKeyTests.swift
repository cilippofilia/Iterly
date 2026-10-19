//
//  ActivityReloadKeyTests.swift
//  IterlyTests
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct ActivityReloadKeyTests {
    private let context: ModelContext

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Project.self, configurations: configuration)
        context = ModelContext(container)
    }

    @Test func sameInputsGiveSameKey() {
        let project = Project(title: "P")
        context.insert(project)
        let task = ProjectTask(title: "T", project: project)
        context.insert(task)

        let first = ActivityReloadKey.make(range: .threeMonths, projects: [project], tasks: [task])
        let second = ActivityReloadKey.make(range: .threeMonths, projects: [project], tasks: [task])

        #expect(first == second)
    }

    @Test func changesWhenTaskIsTouched() async throws {
        let project = Project(title: "P")
        context.insert(project)
        let task = ProjectTask(title: "T", project: project)
        context.insert(task)

        let before = ActivityReloadKey.make(range: .threeMonths, projects: [project], tasks: [task])
        try await Task.sleep(for: .milliseconds(5))
        task.touch()
        let after = ActivityReloadKey.make(range: .threeMonths, projects: [project], tasks: [task])

        #expect(before != after)
    }

    @Test func changesWhenRangeChanges() {
        let before = ActivityReloadKey.make(range: .threeMonths, projects: [], tasks: [])
        let after = ActivityReloadKey.make(range: .sixMonths, projects: [], tasks: [])

        #expect(before != after)
    }
}
