//
//  ActivityWidgetProjectSummary.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation

/// A lightweight, `Sendable` snapshot of a project for the widget's "recently worked on" list.
/// The `Project` `@Model` can't cross the widget-snapshot boundary, so the builder flattens the
/// fields the widget renders (type icon, status color, progress) into this value type.
public struct ActivityWidgetProjectSummary: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let title: String
    public let type: ProjectType
    public let status: ProjectStatus
    /// Share of top-level tasks marked done, in `0...1`.
    public let progress: Double
    public let lastUpdated: Date

    public init(
        id: UUID,
        title: String,
        type: ProjectType,
        status: ProjectStatus,
        progress: Double,
        lastUpdated: Date
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.status = status
        self.progress = progress
        self.lastUpdated = lastUpdated
    }
}
