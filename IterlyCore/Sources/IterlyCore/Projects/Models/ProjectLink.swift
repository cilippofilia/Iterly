//
//  ProjectLink.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 31/03/2026.
//

import Foundation
import SwiftData

public enum ProjectLinkKind: String, CaseIterable, Codable, Identifiable, Sendable {
    case github
    case gitlab
    case website
    case figma
    case testflight
    case custom

    public var id: String {
        rawValue
    }

    public var title: String {
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

    public var systemImage: String {
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
    public static func detected(fromURL url: String) -> ProjectLinkKind? {
        if url.localizedStandardContains("testflight.apple.com") {
            return .testflight
        }
        return nil
    }
}

public struct ProjectLinkInput: Sendable {
    public let kind: ProjectLinkKind
    public let label: String
    public let url: String
    public let sortOrder: Int

    public init(kind: ProjectLinkKind, label: String, url: String, sortOrder: Int) {
        self.kind = kind
        self.label = label
        self.url = url
        self.sortOrder = sortOrder
    }
}

@Model
public final class ProjectLink: Identifiable {
    public var id: UUID = UUID()
    public var label: String = ""
    public var url: String = ""
    public var sortOrder: Int = 0
    private var kindRawValue: String = ProjectLinkKind.website.rawValue

    public var projectRelease: ProjectRelease?

    public var kind: ProjectLinkKind {
        get { ProjectLinkKind(rawValue: kindRawValue) ?? .website }
        set { kindRawValue = newValue.rawValue }
    }

    public init(
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
