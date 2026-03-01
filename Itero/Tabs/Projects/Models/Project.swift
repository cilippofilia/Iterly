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
    var id: UUID
    var title: String
    var details: String?
    var priority: Project.Priority
    var status: Project.Status
    var highlight: ProjectColor
    var startDate: Date?
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
        projectPriority: Project.Priority = .default,
        projectStatus: Project.Status = .default,
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

// MARK: Enums
extension Project {
    enum Priority: String, CaseIterable, Codable {
        static let `default` = Self.notSet

        case notSet
        case low
        case normal
        case high
    }

    enum Status: String, CaseIterable, Codable {
        static let `default` = Self.notSet

        case notSet
        case notStarted
        case inProgress
        case done
    }
}
