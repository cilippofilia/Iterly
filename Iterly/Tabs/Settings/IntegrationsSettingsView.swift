//
//  IntegrationsSettingsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 3/31/26.
//

import SwiftData
import SwiftUI

struct IntegrationsSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        sort: [
            SortDescriptor(\Project.lastUpdated, order: .reverse),
            SortDescriptor(\Project.creationDate, order: .reverse)
        ]
    )
    private var projects: [Project]

    @State private var viewModel: IntegrationsSettingsViewModel

    init(presetStore: CustomLinkLabelPresetStore = CustomLinkLabelPresetStore()) {
        _viewModel = State(initialValue: IntegrationsSettingsViewModel(presetStore: presetStore))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            appStoreSection()
            usefulLinksSection()
            customLinkLabelsSection()
            disconnectAllSection()
        }
        .navigationTitle("Integrations")
        .onChange(of: projects, initial: true) { _, newProjects in
            viewModel.updateProjects(newProjects)
            viewModel.reloadPresets()
        }
        .alert("Integration Error", isPresented: isShowingErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.activeErrorMessage ?? "Something went wrong.")
        }
        .alert(item: $viewModel.pendingAction) { action in
            let title = action.title
            let message = action.message

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .destructive(Text("Remove")) {
                    viewModel.performPendingAction(modelContext: modelContext)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var isShowingErrorAlert: Binding<Bool> {
        Binding(
            get: { viewModel.activeErrorMessage != nil },
            set: { newValue in
                if newValue == false {
                    viewModel.clearError()
                }
            }
        )
    }

    @ViewBuilder
    private func appStoreSection() -> some View {
        Section("App Store") {
            if viewModel.appStoreLinkedProjects.isEmpty {
                ContentUnavailableView(
                    "No App Store Links",
                    systemImage: "link.badge.plus",
                    description: Text("Connect an App Store app from a project to manage it here.")
                )
            } else {
                ForEach(viewModel.appStoreLinkedProjects) { project in
                    appStoreRow(for: project)
                }
            }
        }
    }

    private func appStoreRow(for project: Project) -> some View {
        let appID = project.currentRelease?.extractedAppStoreAppID ?? "Unavailable"

        return IntegrationRowView(
            title: project.title,
            description: "App ID \(appID)",
            url: nil
        ) {
            viewModel.queue(.appStore(project))
        }
    }

    @ViewBuilder
    private func usefulLinksSection() -> some View {
        Section("Useful Links") {
            if viewModel.usefulLinkProjects.isEmpty {
                ContentUnavailableView(
                    "No Useful Links",
                    systemImage: "link",
                    description: Text("Add project links like GitHub, Website, Figma, or socials to manage them here.")
                )
            } else {
                ForEach(viewModel.usefulLinkProjects) { project in
                    usefulLinkRows(for: project)
                }
            }
        }
    }

    @ViewBuilder
    private func usefulLinkRows(for project: Project) -> some View {
        if let release = project.currentRelease {
            ForEach(release.usefulLinks) { link in
                usefulLinkRow(link, for: project)
            }
        }
    }

    private func usefulLinkRow(_ link: ProjectLink, for project: Project) -> some View {
        IntegrationRowView(
            title: project.title,
            description: link.label,
            url: link.url
        ) {
            viewModel.queue(.usefulLink(project, link))
        }
    }

    @ViewBuilder
    private func customLinkLabelsSection() -> some View {
        if viewModel.customLinkLabelPresets.isEmpty == false {
            Section {
                ForEach(viewModel.customLinkLabelPresets, id: \.self) { label in
                    customLinkLabelRow(for: label)
                }
            } header: {
                Text("Custom Link Labels")
            } footer: {
                Text("These are reusable custom labels shown in the project form when you add useful links.")
            }
        }
    }

    private func customLinkLabelRow(for label: String) -> some View {
        IntegrationRowView(
            title: label,
            description: nil,
            url: nil
        ) {
            viewModel.queue(.customLabel(label))
        }
    }

    @ViewBuilder
    private func disconnectAllSection() -> some View {
        if viewModel.hasAnyLinks {
            Section {
                Button("Disconnect All Links", role: .destructive) {
                    viewModel.queue(.allLinks)
                }
            } footer: {
                Text("This removes all stored App Store and useful links from projects but keeps the projects, tasks, and release records.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        IntegrationsSettingsPreview()
    }
    .modelContainer(IntegrationsSettingsPreviewData.makeContainer())
}

private struct IntegrationsSettingsPreview: View {
    private static let defaultsSuite = "IntegrationsSettingsView.preview"
    private let previewDefaults = UserDefaults(suiteName: Self.defaultsSuite) ?? .standard

    init() {
        let presets = ["Press Kit", "Docs", "Community"]

        if let data = try? JSONEncoder().encode(presets),
           let encoded = String(data: data, encoding: .utf8) {
            previewDefaults.set(encoded, forKey: "project.customLinkLabelPresets")
        }
    }

    var body: some View {
        IntegrationsSettingsView(
            presetStore: CustomLinkLabelPresetStore(defaults: previewDefaults)
        )
    }
}

private enum IntegrationsSettingsPreviewData {
    @MainActor
    static func makeContainer() -> ModelContainer {
        let schema = Schema([Project.self, ProjectTask.self, ProjectRelease.self, ProjectLink.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext

            let appProject = Project(
                title: "Drinko.",
                details: "Cocktail masterclass app",
                projectType: .app,
                projectPriority: .medium,
                projectStatus: .live
            )
            let appRelease = ProjectRelease(
                version: "2.3",
                appStoreURL: "https://apps.apple.com/gb/app/drinko/id6449893371",
                appStoreSyncDate: .now,
                project: appProject
            )
            let githubLink = ProjectLink(
                kind: .github,
                label: "GitHub",
                url: "https://github.com/example/drinko",
                sortOrder: 0,
                projectRelease: appRelease
            )
            let websiteLink = ProjectLink(
                kind: .website,
                label: "Website",
                url: "https://drinko.app",
                sortOrder: 1,
                projectRelease: appRelease
            )
            appRelease.links = [githubLink, websiteLink]
            appProject.currentRelease = appRelease

            let designProject = Project(
                title: "Brand Refresh",
                details: "Marketing site and assets",
                projectType: .website,
                projectPriority: .low,
                projectStatus: .dev
            )
            let designRelease = ProjectRelease(version: "1.1", project: designProject)
            let figmaLink = ProjectLink(
                kind: .figma,
                label: "Figma",
                url: "https://www.figma.com/file/example",
                sortOrder: 0,
                projectRelease: designRelease
            )
            let customLink = ProjectLink(
                kind: .custom,
                label: "Press Kit",
                url: "https://example.com/press",
                sortOrder: 1,
                projectRelease: designRelease
            )
            designRelease.links = [figmaLink, customLink]
            designProject.currentRelease = designRelease

            context.insert(appProject)
            context.insert(appRelease)
            context.insert(githubLink)
            context.insert(websiteLink)
            context.insert(designProject)
            context.insert(designRelease)
            context.insert(figmaLink)
            context.insert(customLink)

            try context.save()
            return container
        } catch {
            fatalError("Failed to create integrations preview container: \(error)")
        }
    }
}
