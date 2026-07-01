//
//  TaskAttachment.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import SwiftData

@Model
final class TaskAttachment: Identifiable {
    var id: UUID = UUID()
    var kind: TaskAttachmentKind = TaskAttachmentKind.default

    @Attribute(.externalStorage)
    var data: Data? = nil

    @Attribute(.externalStorage)
    var thumbnailData: Data? = nil

    var fileExtension: String? = nil
    var creationDate: Date = Date.now
    var task: ProjectTask?

    init(
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
