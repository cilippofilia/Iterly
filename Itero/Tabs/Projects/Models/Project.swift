//
//  Project.swift
//  Itero
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftData

@Model
final class Project: Identifiable {
    var id: UUID = UUID()
    var title: String? = "Project Title"
    var details: String? = nil
    var priority: ProjectPriority? = ProjectPriority.default
    var status: ProjectStatus? = ProjectStatus.default
    var highlight: ProjectColor? = ProjectColor.accentColor
    var startDate: Date? = nil
    var dueDate: Date?
    var creationDate: Date
    var isPinned: Bool

    @Relationship(deleteRule: .cascade, inverse: \ProjectTask.project)
    var tasks: [ProjectTask]?

    var completionAmount: Double {
        let originalTasks = tasks ?? []
        guard originalTasks.isEmpty == false else { return 0 }

        let completedTasks = originalTasks.filter { $0.status == .done }
        return Double(completedTasks.count) / Double(originalTasks.count)
    }

    init(
        id: UUID = UUID(),
        title: String = "",
        details: String? = nil,
        projectPriority: ProjectPriority = .default,
        projectStatus: ProjectStatus = .default,
        color: ProjectColor = ProjectColor.accentColor,
        tasks: [ProjectTask]? = [],
        startDate: Date? = nil,
        dueDate: Date? = nil,
        creationDate: Date = .now,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.priority = projectPriority
        self.status = projectStatus
        self.highlight = color
        self.tasks = tasks
        self.startDate = startDate
        self.dueDate = dueDate
        self.creationDate = creationDate
        self.isPinned = isPinned
    }
}
