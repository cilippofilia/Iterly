//
//  ProjectViewModelTests.swift
//  IterlyTests
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct ProjectViewModelTests {
    private let context: ModelContext
    private let viewModel = ProjectViewModel()

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, ProjectTask.self, TaskAttachment.self, ProjectRelease.self, ProjectLink.self,
            configurations: configuration
        )
        context = ModelContext(container)
    }

    private func makeProject(_ title: String, isPinned: Bool) -> Project {
        let project = Project(title: title, isPinned: isPinned)
        context.insert(project)
        return project
    }

    @Test func pinningFifthProjectReportsLimit() throws {
        for index in 1...4 {
            _ = makeProject("Pinned \(index)", isPinned: true)
        }
        let fifth = makeProject("Fifth", isPinned: false)
        try context.save()

        let result = try viewModel.togglePin(project: fifth, modelContext: context)

        #expect(result == .limitReached)
        #expect(fifth.isPinned == false)
    }

    @Test func unpinningAlwaysSucceeds() throws {
        for index in 1...3 {
            _ = makeProject("Pinned \(index)", isPinned: true)
        }
        let pinned = makeProject("Pinned 4", isPinned: true)
        try context.save()

        let result = try viewModel.togglePin(project: pinned, modelContext: context)

        #expect(result == .toggled)
        #expect(pinned.isPinned == false)
    }
}
