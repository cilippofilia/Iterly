//
//  DashboardViewModelTests.swift
//  IterlyTests
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct DashboardViewModelTests {
    private let context: ModelContext
    private let viewModel = DashboardViewModel()
    private let baseDate = Date(timeIntervalSinceReferenceDate: 800_000_000)

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Project.self, configurations: configuration)
        context = ModelContext(container)
    }

    private func makeProject(_ title: String, status: ProjectStatus) -> Project {
        let project = Project(title: title, projectStatus: status)
        context.insert(project)
        return project
    }

    @Test func activeProjectsExcludesClosedProjects() {
        let projects = [
            makeProject("Planning", status: .plan),
            makeProject("Closed", status: .closed),
            makeProject("Live", status: .live)
        ]

        let active = viewModel.activeProjects(from: projects)

        #expect(active.map(\.title) == ["Planning", "Live"])
    }

    @Test func activeProjectsKeepsEveryNonClosedStatus() {
        let projects = ProjectStatus.allCases.map { makeProject($0.title, status: $0) }

        let active = viewModel.activeProjects(from: projects)

        #expect(active.count == ProjectStatus.allCases.count - 1)
        #expect(active.allSatisfy { $0.status != .closed })
    }

    @Test func upcomingTasksExcludesTasksFromClosedProjects() {
        let activeProject = makeProject("Active", status: .dev)
        let closedProject = makeProject("Closed", status: .closed)

        let activeTask = ProjectTask(
            title: "Active task",
            dueDate: baseDate,
            creationDate: baseDate,
            project: activeProject
        )
        let closedProjectTask = ProjectTask(
            title: "Closed project task",
            dueDate: baseDate,
            creationDate: baseDate,
            project: closedProject
        )
        context.insert(activeTask)
        context.insert(closedProjectTask)

        let upcoming = viewModel.upcomingTasks(from: [activeTask, closedProjectTask])

        #expect(upcoming.map(\.title) == ["Active task"])
    }
}
