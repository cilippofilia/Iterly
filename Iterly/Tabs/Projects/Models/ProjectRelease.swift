//
//  ProjectRelease.swift
//  Iterly
//
//  Created by Filippo Cilia on 04/03/2026.
//

import Foundation
import SwiftData

@Model
final class ProjectRelease: Identifiable {
    var id: UUID = UUID()
    var version: String = ""
    // Legacy persisted field kept so existing stores continue to open cleanly.
    var build: String = ""
    @Attribute(originalName: "appURL")
    var appStoreURL: String = ""
    // Legacy persisted field kept so existing stores can migrate to ProjectLink.
    var githubURL: String = ""
    var appStoreSyncDate: Date? = nil
    var appStoreSyncError: String? = nil

    @Relationship(inverse: \Project.currentRelease)
    var project: Project

    @Relationship(deleteRule: .cascade, inverse: \ProjectLink.projectRelease)
    var links: [ProjectLink]?

    init(
        id: UUID = UUID(),
        version: String = "",
        build: String = "",
        appStoreURL: String = "",
        githubURL: String = "",
        appStoreSyncDate: Date? = nil,
        appStoreSyncError: String? = nil,
        project: Project
    ) {
        self.id = id
        self.version = version
        self.build = build
        self.appStoreURL = appStoreURL
        self.githubURL = githubURL
        self.appStoreSyncDate = appStoreSyncDate
        self.appStoreSyncError = appStoreSyncError
        self.project = project
    }

    var hasAppStoreLink: Bool {
        appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var hasGitHubLink: Bool {
        usefulLinks.contains { $0.kind == .github }
    }

    var usefulLinks: [ProjectLink] {
        (links ?? []).sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.label.localizedStandardCompare(rhs.label) == .orderedAscending
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    var hasUsefulLinks: Bool {
        usefulLinks.isEmpty == false
    }

    var extractedAppStoreAppID: String? {
        let trimmedURL = appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedURL.isEmpty == false else { return nil }
        guard let expression = try? NSRegularExpression(pattern: #"(?i)id(\d+)"#) else { return nil }
        let range = NSRange(trimmedURL.startIndex..<trimmedURL.endIndex, in: trimmedURL)
        guard let match = expression.firstMatch(in: trimmedURL, range: range),
              let captureRange = Range(match.range(at: 1), in: trimmedURL) else {
            return nil
        }

        return String(trimmedURL[captureRange])
    }

    var appStoreSyncDateText: String? {
        guard let appStoreSyncDate else { return nil }
        return appStoreSyncDate.formatted(date: .abbreviated, time: .shortened)
    }
}
