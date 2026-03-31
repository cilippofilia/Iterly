//
//  ContentView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedView") var selectedView: String?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $selectedView) {
            Tab("Home", systemImage: "house", value: HomeView.homeTag) {
                HomeView()
            }

            Tab("Projects", systemImage: "folder", value: ProjectsView.projectsTag) {
                ProjectsView()
            }

            Tab("Activity", systemImage: "chart.bar.xaxis", value: ActivityView.activityTag) {
                ActivityView()
            }

            Tab("Settings", systemImage: "gear", value: SettingsView.settingsTag) {
                SettingsView()
            }
        }
        .task {
            backfillProjectTypesIfNeeded()
            backfillUsefulLinksIfNeeded()
        }
    }

    private func backfillProjectTypesIfNeeded() {
        let descriptor = FetchDescriptor<Project>()

        do {
            let projects = try modelContext.fetch(descriptor)
            let projectsNeedingBackfill = projects.filter(\.needsTypeBackfill)

            guard projectsNeedingBackfill.isEmpty == false else { return }

            for project in projectsNeedingBackfill {
                project.backfillTypeIfNeeded()
            }

            try modelContext.save()
        } catch {
            assertionFailure("Failed to backfill project types: \(error)")
        }
    }

    private func backfillUsefulLinksIfNeeded() {
        let descriptor = FetchDescriptor<ProjectRelease>()

        do {
            let releases = try modelContext.fetch(descriptor)
            var didChange = false

            for release in releases {
                let trimmedGitHubURL = release.githubURL.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedGitHubURL.isEmpty == false else { continue }

                let alreadyBackfilled = release.usefulLinks.contains {
                    $0.kind == .github && $0.url == trimmedGitHubURL
                }

                if alreadyBackfilled == false {
                    let nextSortOrder = release.usefulLinks.count
                    let link = ProjectLink(
                        kind: .github,
                        label: ProjectLinkKind.github.title,
                        url: trimmedGitHubURL,
                        sortOrder: nextSortOrder,
                        projectRelease: release
                    )
                    modelContext.insert(link)
                    release.links = release.usefulLinks + [link]
                    didChange = true
                }

                release.githubURL = ""
                didChange = true
            }

            guard didChange else { return }
            try modelContext.save()
        } catch {
            assertionFailure("Failed to backfill useful links: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.makePreviewContainer())
}
