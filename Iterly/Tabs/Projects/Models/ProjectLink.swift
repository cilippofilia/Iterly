//
//  ProjectLink.swift
//  Iterly
//
//  Created by Filippo Cilia on 31/03/2026.
//

import Foundation
import SwiftData

enum ProjectLinkKind: String, CaseIterable, Codable, Identifiable {
    case github
    case gitlab
    case website
    case figma
    case testflight
    case custom

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .github:
            "GitHub"
        case .gitlab:
            "GitLab"
        case .website:
            "Website"
        case .figma:
            "Figma"
        case .testflight:
            "TestFlight"
        case .custom:
            "Custom"
        }
    }

    var systemImage: String {
        switch self {
        case .github:
            "chevron.left.forwardslash.chevron.right"
        case .gitlab:
            "chevron.left.forwardslash.chevron.right"
        case .website:
            "globe"
        case .figma:
            "scribble.variable"
        case .testflight:
            "fanblades"
        case .custom:
            "link"
        }
    }

    /// The kind that can be inferred from a URL the user entered, if any.
    static func detected(fromURL url: String) -> ProjectLinkKind? {
        if url.localizedStandardContains("testflight.apple.com") {
            return .testflight
        }
        return nil
    }
}

struct ProjectLinkInput: Sendable {
    let kind: ProjectLinkKind
    let label: String
    let url: String
    let sortOrder: Int
}

@Model
final class ProjectLink: Identifiable {
    var id: UUID = UUID()
    var label: String = ""
    var url: String = ""
    var sortOrder: Int = 0
    private var kindRawValue: String = ProjectLinkKind.website.rawValue

    var projectRelease: ProjectRelease?

    var kind: ProjectLinkKind {
        get { ProjectLinkKind(rawValue: kindRawValue) ?? .website }
        set { kindRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        kind: ProjectLinkKind,
        label: String,
        url: String,
        sortOrder: Int,
        projectRelease: ProjectRelease? = nil
    ) {
        self.id = id
        self.kindRawValue = kind.rawValue
        self.label = label
        self.url = url
        self.sortOrder = sortOrder
        self.projectRelease = projectRelease
    }
}
