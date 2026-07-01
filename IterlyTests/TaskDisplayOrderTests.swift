//
//  TaskDisplayOrderTests.swift
//  IterlyTests
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import Testing
@testable import Iterly

@MainActor
struct TaskDisplayOrderTests {
    private let fixture: TaskListFixture
    private let baseDate = Date(timeIntervalSinceReferenceDate: 800_000_000)
    private let oneDay: TimeInterval = 86_400

    init() throws {
        fixture = try TaskListFixture()
    }

    @Test func higherPriorityComesFirst() {
        let tasks = [
            fixture.makeTask("Low", priority: .low, creationDate: baseDate),
            fixture.makeTask("High", priority: .high, creationDate: baseDate),
            fixture.makeTask("Not Set", priority: .notSet, creationDate: baseDate),
            fixture.makeTask("Medium", priority: .medium, creationDate: baseDate)
        ]

        let sorted = tasks.sortedForDisplay()

        #expect(sorted.map(\.title) == ["High", "Medium", "Low", "Not Set"])
    }

    @Test func priorityOutranksDueDate() {
        let tasks = [
            fixture.makeTask("Low, due soon", priority: .low, dueDate: baseDate, creationDate: baseDate),
            fixture.makeTask("High, undated", priority: .high, creationDate: baseDate)
        ]

        let sorted = tasks.sortedForDisplay()

        #expect(sorted.map(\.title) == ["High, undated", "Low, due soon"])
    }

    @Test func earlierDueDateComesFirstWithinSamePriority() {
        let tasks = [
            fixture.makeTask("Due later", priority: .medium, dueDate: baseDate + 2 * oneDay, creationDate: baseDate),
            fixture.makeTask("Due sooner", priority: .medium, dueDate: baseDate + oneDay, creationDate: baseDate)
        ]

        let sorted = tasks.sortedForDisplay()

        #expect(sorted.map(\.title) == ["Due sooner", "Due later"])
    }

    @Test func undatedTasksComeLastWithinSamePriority() {
        let tasks = [
            fixture.makeTask("Undated", priority: .medium, creationDate: baseDate),
            fixture.makeTask("Dated", priority: .medium, dueDate: baseDate + oneDay, creationDate: baseDate + oneDay)
        ]

        let sorted = tasks.sortedForDisplay()

        #expect(sorted.map(\.title) == ["Dated", "Undated"])
    }

    @Test func creationDateBreaksDueDateTies() {
        let dueDate = baseDate + oneDay
        let tasks = [
            fixture.makeTask("Created second", priority: .medium, dueDate: dueDate, creationDate: baseDate + oneDay),
            fixture.makeTask("Created first", priority: .medium, dueDate: dueDate, creationDate: baseDate)
        ]

        let sorted = tasks.sortedForDisplay()

        #expect(sorted.map(\.title) == ["Created first", "Created second"])
    }

    @Test func creationDateOrdersUndatedTasks() {
        let tasks = [
            fixture.makeTask("Created second", priority: .notSet, creationDate: baseDate + oneDay),
            fixture.makeTask("Created first", priority: .notSet, creationDate: baseDate)
        ]

        let sorted = tasks.sortedForDisplay()

        #expect(sorted.map(\.title) == ["Created first", "Created second"])
    }
}
