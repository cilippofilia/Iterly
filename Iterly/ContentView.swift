//
//  ContentView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import PrivateAds
import SwiftData
import SwiftUI
import IterlyCore

struct ContentView: View {
    @SceneStorage("selectedTab") private var storedTab: AppTab = .dashboard
    @Environment(\.modelContext) private var modelContext
    @Environment(CrossPromoSignal.self) private var crossPromoSignal
    @Environment(RemoveAdsStore.self) private var removeAdsStore

    @State private var tabSelection = TabSelection()
    @State private var interstitialAd: Ad?

    var body: some View {
        @Bindable var tabSelection = tabSelection

        TabView(selection: $tabSelection.selected) {
            Tab("Dashboard", systemImage: "house", value: AppTab.dashboard) {
                DashboardView()
            }

            Tab("Projects", systemImage: "folder", value: AppTab.projects) {
                ProjectsView()
            }

            Tab("Activity", systemImage: "chart.bar.xaxis", value: AppTab.activity) {
                ActivityView()
            }

            Tab("Settings", systemImage: "gear", value: AppTab.settings) {
                SettingsView()
            }
        }
        // Tab bar on iPhone; a sidebar on iPad and macOS.
        .tabViewStyle(.sidebarAdaptable)
        .environment(tabSelection)
        .onAppear { tabSelection.selected = storedTab }
        .onChange(of: tabSelection.selected) { _, newTab in storedTab = newTab }
        .onOpenURL { url in
            if let tab = AppTab(deepLink: url) { tabSelection.selected = tab }
        }
        .task {
            backfillProjectTypesIfNeeded()
            backfillUsefulLinksIfNeeded()
        }
        // A PrivateAds cross-promo ad every 3rd interaction bump (new task, new subtask, new
        // project, or a status change — see `CrossPromoSignal`). Lives here rather than on any
        // one tab since the triggering action can happen from Dashboard, Projects, or Activity;
        // The cover presents over the whole window regardless of which tab is active
        // (full-screen on iOS, a sheet on macOS — see `platformFullScreenCover`).
        // Fetched directly (rather than via PrivateAds's own `.showAd(when:)`) so a failed
        // fetch can't get the trigger stuck — see NineTilesPuzzle's MenuView for the same pattern.
        .platformFullScreenCover(item: $interstitialAd) { ad in
            AdView(advert: ad, config: .crossPromo) {
                CrossPromoRemoveAdsInfoView()
            }
            .macSheetMinimumSize()
        }
        .onChange(of: crossPromoSignal.count) { _, newValue in
            guard removeAdsStore.isAdsRemoved == false, newValue > 0, newValue.isMultiple(of: 3) else { return }
            Task { await refreshInterstitialAd() }
        }
        // Dismiss an ad the user is mid-way through if they buy "Remove Ads" from its own paywall.
        .onChange(of: removeAdsStore.isAdsRemoved) { _, isAdsRemoved in
            guard isAdsRemoved else { return }
            interstitialAd = nil
        }
    }

    private func refreshInterstitialAd() async {
        guard removeAdsStore.isAdsRemoved == false else { return }
        guard let url = AdConfiguration.crossPromo.adsJSONURL else { return }
        interstitialAd = try? await AdStore.fetchRandomAd(
            from: url,
            excludedIDs: AdConfiguration.crossPromo.excludedIDs
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
        .environment(RemoveAdsStore())
}
