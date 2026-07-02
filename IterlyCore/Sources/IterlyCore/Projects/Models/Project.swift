//
//  Project.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftData

@Model
public final class Project: Identifiable, Hashable {
    public var id: UUID = UUID()
    public var title: String = "Project"
    public var details: String? = nil
    public var note: String? = nil
    private var typeRawValue: String? = nil
    public var priority: ProjectPriority = ProjectPriority.default
    public var status: ProjectStatus = ProjectStatus.default
    public var creationDate: Date = Date.now
    public var lastUpdated: Date = Date.now
    public var isPinned: Bool = false
    public var currentRelease: ProjectRelease?

    @Relationship(deleteRule: .cascade, inverse: \ProjectTask.project)
    public var tasks: [ProjectTask]?

    public var type: ProjectType {
        get { ProjectType(rawValue: typeRawValue ?? "") ?? .default }
        set { typeRawValue = newValue.rawValue }
    }

    public var needsTypeBackfill: Bool {
        typeRawValue == nil
    }

    public var topLevelTasks: [ProjectTask] {
        (tasks ?? [])
            .filter { $0.parentTask == nil }
            .sortedForDisplay()
    }

    public var inProgressAmount: Double {
        let originalTasks = topLevelTasks
        guard originalTasks.isEmpty == false else { return 0 }

        let inProgressTasks = originalTasks.filter { $0.status == .inProgress }
        return Double(inProgressTasks.count) / Double(originalTasks.count)
    }
    public var blockedAmount: Double {
        let originalTasks = topLevelTasks
        guard originalTasks.isEmpty == false else { return 0 }

        let blockedTasks = originalTasks.filter { $0.status == .blocked }
        return Double(blockedTasks.count) / Double(originalTasks.count)
    }
    public var doneAmount: Double {
        let originalTasks = topLevelTasks
        guard originalTasks.isEmpty == false else { return 0 }

        let completedTasks = originalTasks.filter { $0.status == .done }
        return Double(completedTasks.count) / Double(originalTasks.count)
    }

    public init(
        id: UUID = UUID(),
        title: String = "Project",
        details: String? = nil,
        note: String? = nil,
        projectType: ProjectType = ProjectType.default,
        projectPriority: ProjectPriority = ProjectPriority.default,
        projectStatus: ProjectStatus = ProjectStatus.default,
        tasks: [ProjectTask]? = [],
        creationDate: Date = Date.now,
        lastUpdated: Date = Date.now,
        isPinned: Bool = false,
        currentRelease: ProjectRelease? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.note = note
        self.typeRawValue = projectType.rawValue
        self.priority = projectPriority
        self.status = projectStatus
        self.tasks = tasks
        self.creationDate = creationDate
        self.lastUpdated = lastUpdated
        self.isPinned = isPinned
        self.currentRelease = currentRelease
        self.currentRelease?.project = self
    }

    public func touch() {
        lastUpdated = .now
    }

    public func backfillTypeIfNeeded() {
        guard needsTypeBackfill else { return }
        typeRawValue = ProjectType.default.rawValue
    }

    // MARK: HASHABLE CONFORMANCE METHODS
    public static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
