//
//  ProjectLinkDraft.swift
//  Iterly
//
//  Created by Filippo Cilia on 31/03/2026.
//

import Foundation

struct ProjectLinkDraft: Identifiable {
    var id: UUID = UUID()
    var kind: ProjectLinkKind
    var customLabel: String = ""
    var url: String = ""

    init(kind: ProjectLinkKind, customLabel: String = "", url: String = "") {
        self.kind = kind
        self.customLabel = customLabel
        self.url = url
    }

    init(link: ProjectLink) {
        self.id = link.id
        self.kind = link.kind
        self.customLabel = link.kind == .custom ? link.label : ""
        self.url = link.url
    }

    var displayLabel: String {
        if kind == .custom {
            return persistedLabel.isEmpty ? "Choose Label" : persistedLabel
        }
        return kind.title
    }

    var persistedLabel: String {
        let trimmedCustomLabel = customLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if kind == .custom {
            return trimmedCustomLabel
        }
        return kind.title
    }

    @MainActor
    static func makeDrafts(from release: ProjectRelease?) -> [ProjectLinkDraft] {
        guard let release else { return [] }

        var drafts = release.usefulLinks.map(Self.init(link:))
        let legacyGitHubURL = release.githubURL.trimmingCharacters(in: .whitespacesAndNewlines)

        if legacyGitHubURL.isEmpty == false,
           drafts.contains(where: { $0.kind == .github && $0.url == legacyGitHubURL }) == false {
            drafts.append(
                ProjectLinkDraft(
                    kind: .github,
                    customLabel: "",
                    url: legacyGitHubURL
                )
            )
        }

        return drafts
    }
}
