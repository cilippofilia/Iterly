//
//  ProjectSelectionTests.swift
//  IterlyTests
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct ProjectSelectionTests {
    private let context: ModelContext

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Project.self, configurations: configuration)
        context = ModelContext(container)
    }

    private func makeProject(_ title: String) -> Project {
        let project = Project(title: title, projectStatus: .plan)
        context.insert(project)
        return project
    }

    @Test func keepsSelectionThatStillExists() {
        let first = makeProject("A")
        let second = makeProject("B")
        #expect(ProjectSelection.validated(first, in: [first, second]) === first)
    }

    @Test func clearsSelectionAfterDeletion() {
        let first = makeProject("A")
        let second = makeProject("B")
        #expect(ProjectSelection.validated(first, in: [second]) == nil)
    }

    @Test func nilStaysNil() {
        let first = makeProject("A")
        #expect(ProjectSelection.validated(nil, in: [first]) == nil)
    }

    @Test func clearsSelectionAfterRealDeletion() throws {
        let first = makeProject("A")
        let second = makeProject("B")
        try context.save()
        context.delete(first)
        try context.save()
        let remaining = try context.fetch(FetchDescriptor<Project>())
        #expect(remaining.count == 1)
        #expect(ProjectSelection.validated(first, in: remaining) == nil)
        #expect(ProjectSelection.validated(second, in: remaining) === second)
    }
}
