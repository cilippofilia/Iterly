//
//  TaskAttachment.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import SwiftData

@Model
public final class TaskAttachment: Identifiable {
    public var id: UUID = UUID()
    public var kind: TaskAttachmentKind = TaskAttachmentKind.default

    @Attribute(.externalStorage)
    public var data: Data? = nil

    @Attribute(.externalStorage)
    public var thumbnailData: Data? = nil

    public var fileExtension: String? = nil
    public var creationDate: Date = Date.now
    public var task: ProjectTask?

    public init(
        id: UUID = UUID(),
        kind: TaskAttachmentKind = .default,
        data: Data? = nil,
        thumbnailData: Data? = nil,
        fileExtension: String? = nil,
        creationDate: Date = .now,
        task: ProjectTask? = nil
    ) {
        self.id = id
        self.kind = kind
        self.data = data
        self.thumbnailData = thumbnailData
        self.fileExtension = fileExtension
        self.creationDate = creationDate
        self.task = task
    }
}
