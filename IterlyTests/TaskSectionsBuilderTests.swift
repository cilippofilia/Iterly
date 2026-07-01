//
//  TaskSectionsBuilderTests.swift
//  IterlyTests
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import Testing
@testable import Iterly

@MainActor
struct TaskSectionsBuilderTests {
    private let fixture: TaskListFixture
    private let baseDate = Date(timeIntervalSinceReferenceDate: 800_000_000)

    init() throws {
        fixture = try TaskListFixture()
    }

    @Test func sectionsSplitTasksByStatus() {
        let tasks = [
            fixture.makeTask("Active", creationDate: baseDate, status: .inProgress),
            fixture.makeTask("Done", creationDate: baseDate, status: .done),
            fixture.makeTask("Closed", creationDate: baseDate, status: .closed),
            fixture.makeTask("Blocked", creationDate: baseDate, status: .blocked)
        ]

        let sections = TaskSectionsBuilder.sections(for: tasks)

        #expect(sections.active.map(\.title) == ["Active", "Blocked"])
        #expect(sections.completed.map(\.title) == ["Done"])
        #expect(sections.closed.map(\.title) == ["Closed"])
    }

    @Test func eachSectionIsInDisplayOrder() {
        let tasks = [
            fixture.makeTask("Active low", priority: .low, creationDate: baseDate, status: .notStarted),
            fixture.makeTask("Done low", priority: .low, creationDate: baseDate, status: .done),
            fixture.makeTask("Active high", priority: .high, creationDate: baseDate, status: .inProgress),
            fixture.makeTask("Done high", priority: .high, creationDate: baseDate, status: .done)
        ]

        let sections = TaskSectionsBuilder.sections(for: tasks)

        #expect(sections.active.map(\.title) == ["Active high", "Active low"])
        #expect(sections.completed.map(\.title) == ["Done high", "Done low"])
    }
}
