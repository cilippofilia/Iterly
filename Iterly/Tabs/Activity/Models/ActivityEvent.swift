//
//  ActivityEvent.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

struct ActivityEvent: Identifiable, Hashable {
    let date: Date
    let kind: ActivityEventKind
    let title: String
    let context: String
    let projectType: ProjectType?

    var id: String {
        [
            String(date.timeIntervalSinceReferenceDate),
            kind.rawValue,
            title,
            context,
            projectType?.rawValue ?? ""
        ].joined(separator: "|")
    }

    var categoryTitle: String {
        projectType?.title ?? kind.title
    }

    var categorySystemImage: String {
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
