//
//  IntegrationsSettingsViewModel.swift
//  Iterly
//
//  Created by Filippo Cilia on 31/03/2026.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class IntegrationsSettingsViewModel {
    var appStoreLinkedProjects: [Project] = []
    var usefulLinkProjects: [Project] = []
    var customLinkLabelPresets: [String]
    var activeErrorMessage: String?
    var pendingAction: PendingAction?

    private let projectViewModel: ProjectViewModel
    private let presetStore: CustomLinkLabelPresetStore

    init(
        presetStore: CustomLinkLabelPresetStore
    ) {
        self.projectViewModel = ProjectViewModel()
        self.presetStore = presetStore
        self.customLinkLabelPresets = presetStore.load()
    }

    convenience init() {
        self.init(presetStore: CustomLinkLabelPresetStore())
    }

    var hasAnyLinks: Bool {
        appStoreLinkedProjects.isEmpty == false || usefulLinkProjects.isEmpty == false
    }

    func updateProjects(_ projects: [Project]) {
        appStoreLinkedProjects = projects.filter { $0.currentRelease?.hasAppStoreLink == true }
        usefulLinkProjects = projects.filter { $0.currentRelease?.hasUsefulLinks == true }
    }

    func reloadPresets() {
        customLinkLabelPresets = presetStore.load()
    }

    func queue(_ action: PendingAction) {
        pendingAction = action
    }

    func clearError() {
        activeErrorMessage = nil
    }

    func performPendingAction(modelContext: ModelContext) {
        guard let pendingAction else { return }
        self.pendingAction = nil

        switch pendingAction {
        case .appStore(let project):
            disconnectAppStore(project, modelContext: modelContext)
        case .usefulLink(let project, let link):
            disconnectUsefulLink(link, from: project, modelContext: modelContext)
        case .customLabel(let label):
            deleteCustomLabel(label)
        case .allLinks:
            disconnectAllLinks(modelContext: modelContext)
        }
    }

    private func disconnectAppStore(_ project: Project, modelContext: ModelContext) {
        do {
            try projectViewModel.disconnectAppStoreRelease(for: project, modelContext: modelContext)
            activeErrorMessage = nil
        } catch {
            activeErrorMessage = error.localizedDescription
        }
    }

    private func disconnectUsefulLink(
        _ link: ProjectLink,
        from project: Project,
        modelContext: ModelContext
    ) {
        do {
            try projectViewModel.disconnectUsefulLink(link, from: project, modelContext: modelContext)
            activeErrorMessage = nil
        } catch {
            activeErrorMessage = error.localizedDescription
        }
    }

    private func disconnectAllLinks(modelContext: ModelContext) {
        do {
            try projectViewModel.disconnectAllLinks(modelContext: modelContext)
            activeErrorMessage = nil
        } catch {
            activeErrorMessage = error.localizedDescription
        }
    }

    private func deleteCustomLabel(_ label: String) {
        do {
            try presetStore.delete(label)
            reloadPresets()
            activeErrorMessage = nil
        } catch {
            activeErrorMessage = error.localizedDescription
        }
    }
}
