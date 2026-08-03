//
//  ProjectEntity.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 03/08/2026.
//

import AppIntents
import Foundation

/// The `AppEntity` projection of `Project` used by the large Activity widget's configuration,
/// letting people pick specific projects to pin to the widget instead of the automatic latest 4.
public struct ProjectEntity: AppEntity {
    public let id: UUID
    public let title: String
    public let typeSystemImage: String

    public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Project"
    public static let defaultQuery = ProjectEntityQuery()

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", image: .init(systemName: typeSystemImage))
    }

    public init(id: UUID, title: String, typeSystemImage: String) {
        self.id = id
        self.title = title
        self.typeSystemImage = typeSystemImage
    }

    init(project: Project) {
        self.init(id: project.id, title: project.title, typeSystemImage: project.type.systemImage)
    }
}
