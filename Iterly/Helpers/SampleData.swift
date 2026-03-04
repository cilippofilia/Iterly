//
//  SampleData.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import Foundation
import SwiftData

enum SampleData {
    @MainActor
    static let previewContainer: ModelContainer = {
        let schema = Schema([Project.self, ProjectTask.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext
            seedIfNeeded(in: context)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()

    @MainActor
    static func seedIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<Project>()

        do {
            let count = try context.fetchCount(descriptor)
            guard count == 0 else { return }

            let projects = makeProjects()
            for project in projects {
                context.insert(project)
                project.tasks?.forEach { context.insert($0) }
            }

            try context.save()
        } catch {
            assertionFailure("Sample data seeding failed: \(error)")
        }
    }

    @MainActor
    static func insertSample(in context: ModelContext) {
        let projects = makeProjects()

        do {
            for project in projects {
                context.insert(project)
                project.tasks?.forEach { context.insert($0) }
            }

            try context.save()
        } catch {
            assertionFailure("Sample data insert failed: \(error)")
        }
    }

    @MainActor
    static func makeProjects() -> [Project] {
        let calendar = Calendar.current
        let now = Date.now

        let onboarding = Project(
            title: "Drinko.",
            details: "Cocktail making masterclass at your fingertips.",
            projectPriority: .high,
            projectStatus: .inProgress,
            startDate: now,
            dueDate: calendar.date(byAdding: .day, value: 14, to: now),
            creationDate: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            isPinned: true
        )

        let onboardingTasks = [
            ProjectTask(title: "Design the welcome flow", status: .inProgress, priority: .high, project: onboarding),
            ProjectTask(title: "Write onboarding copy", status: .notStarted, priority: .normal, project: onboarding),
            ProjectTask(title: "QA localization", status: .notStarted, priority: .normal, project: onboarding),
            ProjectTask(title: "NA Release", status: .done, priority: .normal, project: onboarding),
            ProjectTask(title: "IR Release", status: .done, priority: .normal, project: onboarding),
            ProjectTask(title: "UK Release", status: .done, priority: .normal, project: onboarding)
        ]
        onboarding.tasks = onboardingTasks

        let insights = Project(
            title: "Insights",
            details: "Weekly reporting",
            projectPriority: .normal,
            projectStatus: .notStarted,
            startDate: calendar.date(byAdding: .day, value: 2, to: now),
            dueDate: calendar.date(byAdding: .day, value: 30, to: now),
            creationDate: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
            isPinned: false
        )

        let insightsTasks = [
            ProjectTask(title: "Define report metrics", status: .notStarted, priority: .high, project: insights),
            ProjectTask(title: "Prototype charts", status: .notStarted, priority: .normal, project: insights)
        ]
        insights.tasks = insightsTasks

        let marketing = Project(
            title: "Launch Plan",
            details: "Campaign and timeline",
            projectPriority: .low,
            projectStatus: .notStarted,
            startDate: calendar.date(byAdding: .day, value: 7, to: now),
            dueDate: calendar.date(byAdding: .day, value: 45, to: now),
            creationDate: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            isPinned: false
        )

        let marketingTasks = [
            ProjectTask(title: "Draft announcement", status: .notStarted, priority: .normal, project: marketing),
            ProjectTask(title: "Prepare assets", status: .notStarted, priority: .normal, project: marketing)
        ]
        marketing.tasks = marketingTasks

        let cleanup = Project(
            title: "Tech Cleanup",
            details: "Reduce tech debt",
            projectPriority: .normal,
            projectStatus: .inProgress,
            startDate: calendar.date(byAdding: .day, value: -2, to: now),
            dueDate: calendar.date(byAdding: .day, value: 21, to: now),
            creationDate: calendar.date(byAdding: .day, value: -10, to: now) ?? now,
            isPinned: false
        )

        let cleanupTasks = [
            ProjectTask(title: "Remove legacy screens", status: .inProgress, priority: .normal, project: cleanup),
            ProjectTask(title: "Update API clients", status: .notStarted, priority: .high, project: cleanup),
            ProjectTask(title: "Audit permissions", status: .notStarted, priority: .normal, project: cleanup)
        ]
        cleanup.tasks = cleanupTasks

        return [onboarding, insights, marketing, cleanup]
    }
}
