//
//  ProjectTask.swift
//  Itero
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftData

@Model
final class ProjectTask: Identifiable {
    var id: UUID
    var title: String
    var details: String?
    var status: TaskStatus
    var startDate: Date?
    var dueDate: Date?
    var priority: TaskPriority
    var creationDate: Date
    var project: Project?

    init(
        id: UUID = UUID(),
        title: String = "",
        details: String? = nil,
        status: TaskStatus = .default,
        startDate: Date? = nil,
        dueDate: Date? = nil,
        priority: TaskPriority = .default,
        creationDate: Date = .now,
        project: Project? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.status = status
        self.startDate = startDate
        self.dueDate = dueDate
        self.priority = priority
        self.creationDate = creationDate
        self.project = project
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case low
    case normal
    case high
}

enum TaskStatus: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case notStarted
    case inProgress
    case done
}
