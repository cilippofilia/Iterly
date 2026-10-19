//
//  ExternalDestination.swift
//  Iterly
//

import Foundation
import IterlyCore

/// A link a project can open externally (App Store page or a useful link).
struct ExternalDestination: Identifiable, Hashable {
    let title: String
    let systemImage: String
    let rawURL: String

    /// Derived from content so the identity survives view body re-evaluation.
    var id: String { "\(title)|\(rawURL)" }

    var displayURL: String {
        rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var resolvedURL: URL? {
        let trimmedURL = displayURL
        guard trimmedURL.isEmpty == false,
              trimmedURL.localizedStandardContains(" ") == false else {
            return nil
        }

        if let url = URL(string: trimmedURL),
           let scheme = url.scheme,
           scheme.isEmpty == false {
            return url
        }

        return URL(string: "https://\(trimmedURL)")
    }

    /// The App Store link first, then the release's useful links in order, skipping blank URLs.
    static func destinations(for release: ProjectRelease?) -> [ExternalDestination] {
        guard let release else { return [] }

        var destinations: [ExternalDestination] = []

        let appStoreURL = release.appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if appStoreURL.isEmpty == false {
            destinations.append(
                ExternalDestination(title: "App Store", systemImage: "apple.logo", rawURL: appStoreURL)
            )
        }

        for link in release.usefulLinks {
            let trimmedURL = link.url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedURL.isEmpty == false else { continue }

            destinations.append(
                ExternalDestination(title: link.label, systemImage: link.kind.systemImage, rawURL: trimmedURL)
            )
        }

        // Collapse repeats so `id` stays unique within the list (first occurrence wins).
        var seen = Set<String>()
        return destinations.filter { seen.insert($0.id).inserted }
    }
}
