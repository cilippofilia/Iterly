//
//  ProjectTask.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftData

@Model
public final class ProjectTask: Identifiable {
    public var id: UUID = UUID()
    public var title: String = "Task"
    public var details: String? = nil
    public var note: String? = nil
    public var status: TaskStatus = TaskStatus.default
    public var dueDate: Date? = nil
    public var priority: TaskPriority = TaskPriority.default
    public var creationDate: Date = Date.now
    public var lastUpdated: Date? = nil
    public var project: Project?

    @Relationship(deleteRule: .cascade)
    public var subtasks: [ProjectTask]?

    @Relationship(inverse: \ProjectTask.subtasks)
    public var parentTask: ProjectTask?

    @Relationship(deleteRule: .cascade, inverse: \TaskAttachment.task)
    public var attachments: [TaskAttachment]?

    public init(
        id: UUID = UUID(),
        title: String = "Task",
        details: String? = nil,
        note: String? = nil,
        status: TaskStatus = TaskStatus.default,
        dueDate: Date? = nil,
        priority: TaskPriority = TaskPriority.default,
        creationDate: Date = Date.now,
        lastUpdated: Date? = nil,
        project: Project,
        subtasks: [ProjectTask]? = nil,
        parentTask: ProjectTask? = nil,
        attachments: [TaskAttachment]? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.note = note
        self.status = status
        self.dueDate = dueDate
        self.priority = priority
        self.creationDate = creationDate
        self.lastUpdated = lastUpdated ?? creationDate
        self.project = project
        self.subtasks = subtasks
        self.parentTask = parentTask
        self.attachments = attachments
    }

    public func touch() {
        lastUpdated = .now
    }
}
