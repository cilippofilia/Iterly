//
//  ContentView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import Billboard
import SwiftData
import SwiftUI
import IterlyCore

struct ContentView: View {
    @AppStorage("selectedView") var selectedView: String?
    @Environment(\.modelContext) private var modelContext
    @Environment(CrossPromoSignal.self) private var crossPromoSignal

    @State private var interstitialAd: BillboardAd?

    var body: some View {
        TabView(selection: $selectedView) {
            Tab("Dashboard", systemImage: "house", value: DashboardView.dashboardTag) {
                DashboardView()
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
        // A Billboard cross-promo ad every 3rd interaction bump (new task, new subtask, new
        // project, or a status change — see `CrossPromoSignal`). Lives here rather than on any
        // one tab since the triggering action can happen from Dashboard, Projects, or Activity;
        // `.fullScreenCover` presents over the whole window regardless of which tab is active.
        // Fetched directly (rather than via Billboard's own `.showBillboard(when:)`) so a failed
        // fetch can't get the trigger stuck — see NineTilesPuzzle's MenuView for the same pattern.
        .fullScreenCover(item: $interstitialAd) { ad in
            BillboardView(advert: ad, config: .crossPromo) {
                CrossPromoRemoveAdsInfoView()
            }
        }
        .onChange(of: crossPromoSignal.count) { _, newValue in
            guard newValue > 0, newValue.isMultiple(of: 3) else { return }
            Task { await refreshInterstitialAd() }
        }
    }

    private func refreshInterstitialAd() async {
        guard let url = BillboardConfiguration.crossPromo.adsJSONURL else { return }
        interstitialAd = try? await BillboardViewModel.fetchRandomAd(
            from: url,
            excludedIDs: BillboardConfiguration.crossPromo.excludedIDs
        )
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

            try modelContext.saveAndReloadActivityWidget()
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
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            assertionFailure("Failed to backfill useful links: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.makePreviewContainer())
        .environment(CrossPromoSignal())
}
