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
        let schema = Schema([Project.self, ProjectTask.self, ProjectRelease.self, ProjectLink.self])
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
    static let emptyPreviewContainer: ModelContainer = {
        let schema = Schema([Project.self, ProjectTask.self, ProjectRelease.self, ProjectLink.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create empty preview container: \(error)")
        }
    }()

    @MainActor
    static func makePreviewContainer() -> ModelContainer {
        let schema = Schema([Project.self, ProjectTask.self, ProjectRelease.self, ProjectLink.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext
            seedIfNeeded(in: context)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }

    @MainActor
    static func makeEmptyPreviewContainer() -> ModelContainer {
        let schema = Schema([Project.self, ProjectTask.self, ProjectRelease.self, ProjectLink.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create empty preview container: \(error)")
        }
    }

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
                if let currentRelease = project.currentRelease {
                    context.insert(currentRelease)
                }
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
                if let currentRelease = project.currentRelease {
                    context.insert(currentRelease)
                }
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

        let onboardingDate = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        let onboarding = Project(
            title: "Drinko.",
            details: "Cocktail making masterclass at your fingertips.",
            note: "Focus on the welcome flow and early retention.",
            projectType: .app,
            projectPriority: .high,
            projectStatus: .live,
            creationDate: onboardingDate,
            lastUpdated: onboardingDate,
            isPinned: true
        )
        onboarding.currentRelease = ProjectRelease(version: "2.2", project: onboarding)

        let onboardingTasks = [
            ProjectTask(title: "Design the welcome flow", details: "Design onboarding to explain key areas of the app - Learn, Cocktails, Cabinet.", note: "Include skip and restore options.", status: .inProgress, priority: .high, project: onboarding),
            ProjectTask(title: "Write onboarding copy", status: .notStarted, priority: .medium, project: onboarding),
            ProjectTask(title: "QA localization", status: .notStarted, priority: .medium, project: onboarding),
            ProjectTask(title: "Migrate analytics events", status: .blocked, priority: .high, project: onboarding),
            ProjectTask(title: "Legal review", status: .blocked, priority: .medium, project: onboarding),
            ProjectTask(title: "Instrument onboarding metrics", status: .inProgress, priority: .high, project: onboarding),
            ProjectTask(title: "Collect beta feedback", status: .inProgress, priority: .low, project: onboarding),
            ProjectTask(title: "Finalize tutorial video", status: .notStarted, priority: .low, project: onboarding),
            ProjectTask(title: "NA Release", status: .done, priority: .medium, project: onboarding),
            ProjectTask(title: "IR Release", status: .done, priority: .medium, project: onboarding),
            ProjectTask(title: "UK Release", status: .done, priority: .medium, project: onboarding),
            ProjectTask(title: "App Store screenshots", status: .done, priority: .low, project: onboarding)
        ]
        let onboardingSubtasks = [
            ProjectTask(title: "Map entry points", note: "Cover onboarding from deep links too.", status: .inProgress, priority: .medium, project: onboarding, parentTask: onboardingTasks[0]),
            ProjectTask(title: "Prepare motion tokens", status: .notStarted, priority: .low, project: onboarding, parentTask: onboardingTasks[0])
        ]
        onboardingTasks[0].subtasks = onboardingSubtasks
        onboarding.tasks = onboardingTasks + onboardingSubtasks

        let insightsDate = calendar.date(byAdding: .day, value: -5, to: now) ?? now
        let insights = Project(
            title: "Insights",
            details: "Weekly reporting",
            projectType: .package,
            projectPriority: .medium,
            projectStatus: .dev,
            creationDate: insightsDate,
            lastUpdated: insightsDate,
            isPinned: false
        )
        insights.currentRelease = ProjectRelease(version: "0.9.2", project: insights)

        let insightsTasks = [
            ProjectTask(title: "Define report metrics", status: .notStarted, priority: .high, project: insights),
            ProjectTask(title: "Prototype charts", status: .notStarted, priority: .medium, project: insights),
            ProjectTask(title: "Prepare data sources", status: .inProgress, priority: .high, project: insights),
            ProjectTask(title: "Review metric definitions", status: .blocked, priority: .medium, project: insights),
            ProjectTask(title: "Baseline report snapshots", status: .done, priority: .low, project: insights)
        ]
        insights.tasks = insightsTasks

        let marketingDate = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let marketing = Project(
            title: "Launch Plan",
            details: "Campaign and timeline",
            projectType: .website,
            projectPriority: .low,
            projectStatus: .plan,
            creationDate: marketingDate,
            lastUpdated: marketingDate,
            isPinned: false
        )
        marketing.currentRelease = ProjectRelease(version: "2.0.0", project: marketing)

        let marketingTasks = [
            ProjectTask(title: "Draft announcement", status: .notStarted, priority: .medium, project: marketing),
            ProjectTask(title: "Prepare assets", status: .notStarted, priority: .medium, project: marketing),
            ProjectTask(title: "Align launch timing", status: .inProgress, priority: .high, project: marketing),
            ProjectTask(title: "Legal approval", status: .blocked, priority: .medium, project: marketing),
            ProjectTask(title: "Press kit final pass", status: .done, priority: .low, project: marketing)
        ]
        marketing.tasks = marketingTasks

        let cleanupDate = calendar.date(byAdding: .day, value: -10, to: now) ?? now
        let cleanup = Project(
            title: "Tech Cleanup",
            details: "Reduce tech debt",
            projectType: .library,
            projectPriority: .medium,
            projectStatus: .blocked,
            creationDate: cleanupDate,
            lastUpdated: cleanupDate,
            isPinned: false
        )
        cleanup.currentRelease = ProjectRelease(version: "3.2.1", project: cleanup)

        let cleanupTasks = [
            ProjectTask(title: "Remove legacy screens", status: .inProgress, priority: .medium, project: cleanup),
            ProjectTask(title: "Update API clients", status: .notStarted, priority: .high, project: cleanup),
            ProjectTask(title: "Audit permissions", status: .notStarted, priority: .medium, project: cleanup),
            ProjectTask(title: "Dependency upgrade plan", status: .blocked, priority: .high, project: cleanup),
            ProjectTask(title: "Purge deprecated flags", status: .done, priority: .low, project: cleanup)
        ]
        cleanup.tasks = cleanupTasks

        let paymentsDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let payments = Project(
            title: "Payments Revamp",
            details: "Streamline checkout and subscriptions.",
            note: "Coordinate with finance on pricing tiers.",
            projectType: .automation,
            projectPriority: .high,
            projectStatus: .dev,
            creationDate: paymentsDate,
            lastUpdated: paymentsDate,
            isPinned: true
        )
        payments.currentRelease = ProjectRelease(version: "1.4.0", project: payments)

        let paymentsTasks = [
            ProjectTask(title: "Map payment flows", details: "Audit one-time and subscription flows.", status: .inProgress, priority: .high, project: payments),
            ProjectTask(title: "Consolidate price tiers", status: .notStarted, priority: .medium, project: payments),
            ProjectTask(title: "Retry logic for failed charges", status: .blocked, priority: .high, project: payments),
            ProjectTask(title: "Receipt validation checks", status: .notStarted, priority: .high, project: payments),
            ProjectTask(title: "Upgrade paywall copy", status: .notStarted, priority: .medium, project: payments),
            ProjectTask(title: "QA sandbox purchases", status: .done, priority: .low, project: payments)
        ]
        let paymentsSubtasks = [
            ProjectTask(title: "Sketch retry states", status: .notStarted, priority: .medium, project: payments, parentTask: paymentsTasks[0])
        ]
        paymentsTasks[0].subtasks = paymentsSubtasks
        payments.tasks = paymentsTasks + paymentsSubtasks

        let communityDate = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        let community = Project(
            title: "Community Beta",
            details: "Invite-only social layer for power users.",
            projectType: .other,
            projectPriority: .medium,
            projectStatus: .plan,
            creationDate: communityDate,
            lastUpdated: communityDate,
            isPinned: false
        )
        community.currentRelease = ProjectRelease(version: "0.3.0", project: community)

        let communityTasks = [
            ProjectTask(title: "Define beta cohort", status: .notStarted, priority: .high, project: community),
            ProjectTask(title: "Moderation rules", status: .notStarted, priority: .medium, project: community),
            ProjectTask(title: "Community guidelines review", status: .blocked, priority: .medium, project: community),
            ProjectTask(title: "Invite workflow prototype", status: .inProgress, priority: .high, project: community),
            ProjectTask(title: "Feedback collection plan", status: .inProgress, priority: .medium, project: community),
            ProjectTask(title: "Welcome post templates", status: .done, priority: .low, project: community)
        ]
        community.tasks = communityTasks

        let designSystemDate = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let designSystem = Project(
            title: "Design System",
            details: "Unify tokens, components, and accessibility.",
            projectType: .agentSkill,
            projectPriority: .low,
            projectStatus: .dev,
            creationDate: designSystemDate,
            lastUpdated: designSystemDate,
            isPinned: false
        )
        designSystem.currentRelease = ProjectRelease(version: "0.7.1", project: designSystem)

        let designSystemTasks = [
            ProjectTask(title: "Audit component library", status: .inProgress, priority: .medium, project: designSystem),
            ProjectTask(title: "Token alignment checklist", status: .notStarted, priority: .medium, project: designSystem),
            ProjectTask(title: "Contrast fixes", status: .notStarted, priority: .high, project: designSystem),
            ProjectTask(title: "Icon sizing rules", status: .done, priority: .low, project: designSystem),
            ProjectTask(title: "Typography scale update", status: .blocked, priority: .medium, project: designSystem)
        ]
        let designSystemSubtasks = [
            ProjectTask(title: "Button states audit", status: .inProgress, priority: .low, project: designSystem, parentTask: designSystemTasks[0]),
            ProjectTask(title: "Input field variants", status: .notStarted, priority: .medium, project: designSystem, parentTask: designSystemTasks[0])
        ]
        designSystemTasks[0].subtasks = designSystemSubtasks
        designSystem.tasks = designSystemTasks + designSystemSubtasks

        return [onboarding, insights, marketing, cleanup, payments, community, designSystem]
    }
}
