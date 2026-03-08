//
//  Project.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftData

@Model
final class Project: Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String = "Project"
    var details: String? = nil
    var note: String? = nil
    var priority: ProjectPriority = ProjectPriority.default
    var status: ProjectStatus = ProjectStatus.default
    var creationDate: Date = Date.now
    var lastUpdated: Date = Date.now
    var isPinned: Bool = false
    var currentRelease: ProjectRelease?

    @Relationship(deleteRule: .cascade, inverse: \ProjectTask.project)
    var tasks: [ProjectTask]?

    var topLevelTasks: [ProjectTask] {
        (tasks ?? []).filter { $0.parentTask == nil }
    }

    var inProgressAmount: Double {
        let originalTasks = topLevelTasks
        guard originalTasks.isEmpty == false else { return 0 }

        let inProgressTasks = originalTasks.filter { $0.status == .inProgress }
        return Double(inProgressTasks.count) / Double(originalTasks.count)
    }
    var blockedAmount: Double {
        let originalTasks = topLevelTasks
        guard originalTasks.isEmpty == false else { return 0 }

        let blockedTasks = originalTasks.filter { $0.status == .blocked }
        return Double(blockedTasks.count) / Double(originalTasks.count)
    }
    var doneAmount: Double {
        let originalTasks = topLevelTasks
        guard originalTasks.isEmpty == false else { return 0 }

        let completedTasks = originalTasks.filter { $0.status == .done }
        return Double(completedTasks.count) / Double(originalTasks.count)
    }

    init(
        id: UUID = UUID(),
        title: String = "Project",
        details: String? = nil,
        note: String? = nil,
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
        self.priority = projectPriority
        self.status = projectStatus
        self.tasks = tasks
        self.creationDate = creationDate
        self.lastUpdated = lastUpdated
        self.isPinned = isPinned
        self.currentRelease = currentRelease
        self.currentRelease?.project = self
    }

    func touch() {
        lastUpdated = .now
    }

    // MARK: HASHABLE CONFORMANCE METHODS
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
