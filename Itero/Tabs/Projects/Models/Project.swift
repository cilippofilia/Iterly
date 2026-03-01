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
    var projectPriority: ProjectPriority
    var projectStatus: ProjectStatus
    @Relationship(deleteRule: .cascade, inverse: \ProjectTask.project)
    var tasks: [ProjectTask]?
    var startDate: Date?
    var dueDate: Date?
    var creationDate: Date
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        title: String = "",
        details: String? = nil,
        projectPriority: ProjectPriority = .default,
        projectStatus: ProjectStatus = .default,
        tasks: [ProjectTask]? = [],
        startDate: Date? = nil,
        dueDate: Date? = nil,
        creationDate: Date = .now,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.projectPriority = projectPriority
        self.projectStatus = projectStatus
        self.tasks = tasks
        self.startDate = startDate
        self.dueDate = dueDate
        self.creationDate = creationDate
        self.isPinned = isPinned
    }
}

enum ProjectPriority: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case low
    case normal
    case high
}

enum ProjectStatus: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case notStarted
    case inProgress
    case done
}
