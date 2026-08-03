//
//  ProjectEntityQuery.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 03/08/2026.
//

import AppIntents
import Foundation
import SwiftData

/// Resolves and searches `Project` records for the widget configuration's project picker.
/// Runs inside the widget extension, so it opens its own `ModelContext` on the shared store
/// rather than going through the app's `@MainActor`-bound container.
public struct ProjectEntityQuery: EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [UUID]) async throws -> [ProjectEntity] {
        let projectsByID = try fetchProjectsByID()
        return identifiers.compactMap { projectsByID[$0] }.map(ProjectEntity.init(project:))
    }

    public func entities(matching string: String) async throws -> [ProjectEntity] {
        try openProjects()
            .filter { $0.status != .closed && $0.title.localizedStandardContains(string) }
            .sorted { $0.lastUpdated > $1.lastUpdated }
            .map(ProjectEntity.init(project:))
    }

    public func suggestedEntities() async throws -> [ProjectEntity] {
        try openProjects()
            .filter { $0.status != .closed }
            .sorted { $0.lastUpdated > $1.lastUpdated }
            .map(ProjectEntity.init(project:))
    }

    private func fetchProjectsByID() throws -> [UUID: Project] {
        Dictionary(uniqueKeysWithValues: try openProjects().map { ($0.id, $0) })
    }

    private func openProjects() throws -> [Project] {
        let context = ModelContext(SharedModelContainer.make())
        return try context.fetch(FetchDescriptor<Project>())
    }
}
