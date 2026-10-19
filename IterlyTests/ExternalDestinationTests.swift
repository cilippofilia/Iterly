//
//  ExternalDestinationTests.swift
//  IterlyTests
//

import Foundation
import SwiftData
import Testing
import IterlyCore
@testable import Iterly

@MainActor
struct ExternalDestinationTests {
    private let context: ModelContext

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Project.self, configurations: configuration)
        context = ModelContext(container)
    }

    private func makeRelease(appStoreURL: String, links: [(String, String)]) -> ProjectRelease {
        let project = Project(title: "Sample")
        context.insert(project)
        let release = ProjectRelease(appStoreURL: appStoreURL, project: project)
        release.links = links.enumerated().map { index, link in
            ProjectLink(
                kind: .website,
                label: link.0,
                url: link.1,
                sortOrder: index,
                projectRelease: release
            )
        }
        project.currentRelease = release
        return release
    }

    @Test func idIsStableAcrossBuilds() {
        let release = makeRelease(
            appStoreURL: "https://apps.apple.com/app/id1",
            links: [("Site", "https://example.com")]
        )

        let first = ExternalDestination.destinations(for: release).map(\.id)
        let second = ExternalDestination.destinations(for: release).map(\.id)

        #expect(first == second)
        #expect(first.count == 2)
    }

    @Test func appStoreComesFirstAndBlankLinksAreSkipped() {
        let release = makeRelease(
            appStoreURL: "  https://apps.apple.com/app/id1  ",
            links: [("Blank", "   "), ("Site", "https://example.com")]
        )

        let destinations = ExternalDestination.destinations(for: release)

        #expect(destinations.map(\.title) == ["App Store", "Site"])
        #expect(destinations.first?.rawURL == "https://apps.apple.com/app/id1")
    }

    @Test func duplicateLinksAreCollapsed() {
        let release = makeRelease(
            appStoreURL: "",
            links: [("Site", "https://example.com"), ("Site", " https://example.com "), ("Docs", "https://example.com")]
        )

        let destinations = ExternalDestination.destinations(for: release)

        #expect(destinations.map(\.title) == ["Site", "Docs"])
        #expect(Set(destinations.map(\.id)).count == destinations.count)
    }

    @Test func nilReleaseHasNoDestinations() {
        #expect(ExternalDestination.destinations(for: nil).isEmpty)
    }
}
