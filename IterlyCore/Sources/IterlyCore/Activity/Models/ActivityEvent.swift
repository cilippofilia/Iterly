//
//  ActivityEvent.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

public struct ActivityEvent: Identifiable, Hashable {
    public let date: Date
    public let kind: ActivityEventKind
    public let title: String
    public let context: String
    public let projectType: ProjectType?

    public init(date: Date, kind: ActivityEventKind, title: String, context: String, projectType: ProjectType?) {
        self.date = date
        self.kind = kind
        self.title = title
        self.context = context
        self.projectType = projectType
    }

    public var id: String {
        [
            String(date.timeIntervalSinceReferenceDate),
            kind.rawValue,
            title,
            context,
            projectType?.rawValue ?? ""
        ].joined(separator: "|")
    }

    public var categoryTitle: String {
        projectType?.title ?? kind.title
    }

    public var categorySystemImage: String {
        projectType?.systemImage ?? fallbackSystemImage
    }

    private var fallbackSystemImage: String {
        switch kind {
        case .project:
            "folder"
        case .task:
            "checklist"
        }
    }
}
