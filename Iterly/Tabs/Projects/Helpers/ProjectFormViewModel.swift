//
//  ProjectFormViewModel.swift
//  Iterly
//
//  Created by Filippo Cilia on 31/03/2026.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ProjectFormViewModel {
    let project: Project?

    var title: String
    var details: String
    var note: String
    var version: String
    var appStoreURL: String
    var usefulLinkDrafts: [ProjectLinkDraft]
    var type: ProjectType
    var priority: ProjectPriority
    var status: ProjectStatus
    var isPinned: Bool
    var isSaving = false
    var syncErrorMessage: String?
    var customLinkLabelPresets: [String]

    private let projectViewModel: ProjectViewModel
    private let presetStore: CustomLinkLabelPresetStore

    init(
        project: Project? = nil,
        presetStore: CustomLinkLabelPresetStore? = nil
    ) {
        self.project = project
        self.projectViewModel = ProjectViewModel()
        self.presetStore = presetStore ?? CustomLinkLabelPresetStore()
        self.title = project?.title ?? ""
        self.details = project?.details ?? ""
        self.note = project?.note ?? ""
        self.version = project?.currentRelease?.version ?? ""
        self.appStoreURL = project?.currentRelease?.appStoreURL ?? ""
        self.usefulLinkDrafts = ProjectLinkDraft.makeDrafts(from: project?.currentRelease)
        self.type = project?.type ?? .default
        self.priority = project?.priority ?? .default
        self.status = project?.status ?? .default
        self.isPinned = project?.isPinned ?? false
        self.customLinkLabelPresets = self.presetStore.load()
    }

    var navigationTitle: String {
        project == nil ? "New Project" : "Edit Project"
    }

    var isEditing: Bool {
        project != nil
    }

    var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && isSaving == false
    }

    var isAppStoreLinked: Bool {
        project?.currentRelease?.hasAppStoreLink == true
    }

    var willSyncFromAppStoreURL: Bool {
        appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var lastSyncText: String? {
        guard isAppStoreLinked else { return nil }
        return project?.currentRelease?.appStoreSyncDateText
    }

    var usefulLinkInputs: [ProjectLinkInput] {
        usefulLinkDrafts.enumerated().compactMap { index, draft in
            let trimmedURL = draft.url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedURL.isEmpty == false else { return nil }

            let label = draft.persistedLabel
            guard label.isEmpty == false else { return nil }

            return ProjectLinkInput(
                kind: draft.kind,
                label: label,
                url: trimmedURL,
                sortOrder: index
            )
        }
    }

    func save(modelContext: ModelContext) async -> Bool {
        isSaving = true
        defer { isSaving = false }

        do {
            if let project {
                try await projectViewModel.updateProject(
                    project,
                    title: title,
                    details: details,
                    note: note,
                    type: type,
                    priority: priority,
                    status: status,
                    isPinned: isPinned,
                    version: version,
                    appStoreURL: appStoreURL,
                    usefulLinks: usefulLinkInputs,
                    modelContext: modelContext
                )
            } else {
                try await projectViewModel.createProject(
                    title: title,
                    details: details,
                    note: note,
                    type: type,
                    priority: priority,
                    status: status,
                    isPinned: isPinned,
                    version: version,
                    appStoreURL: appStoreURL,
                    usefulLinks: usefulLinkInputs,
                    modelContext: modelContext
                )
            }

            try persistCustomLabelPresets()
            syncErrorMessage = nil
            return true
        } catch {
            syncErrorMessage = error.localizedDescription
            return false
        }
    }

    func close(modelContext: ModelContext) async -> Bool {
        status = .closed
        isPinned = false
        return await save(modelContext: modelContext)
    }

    func deleteProject(modelContext: ModelContext) {
        guard let project else { return }
        projectViewModel.deleteProject(project, modelContext: modelContext)
    }

    func refreshLinkedRelease(modelContext: ModelContext) async {
        guard let project else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await projectViewModel.refreshAppStoreRelease(for: project, modelContext: modelContext)
            version = project.currentRelease?.version ?? version
            appStoreURL = project.currentRelease?.appStoreURL ?? appStoreURL
            usefulLinkDrafts = ProjectLinkDraft.makeDrafts(from: project.currentRelease)
            syncErrorMessage = nil
        } catch {
            projectViewModel.saveAppStoreSyncError(error, for: project, modelContext: modelContext)
            syncErrorMessage = error.localizedDescription
        }
    }

    func disconnectLinkedRelease(modelContext: ModelContext) {
        guard let project else { return }

        do {
            try projectViewModel.disconnectAppStoreRelease(for: project, modelContext: modelContext)
            syncErrorMessage = nil
        } catch {
            syncErrorMessage = error.localizedDescription
        }
    }

    func addUsefulLinkDraft() {
        usefulLinkDrafts.append(.init(kind: .website))
    }

    func removeUsefulLinkDraft(_ id: UUID) {
        usefulLinkDrafts.removeAll { $0.id == id }
    }

    func clearSyncError() {
        syncErrorMessage = nil
    }

    private func persistCustomLabelPresets() throws {
        let newPresets = usefulLinkDrafts
            .filter { $0.kind == .custom }
            .map(\.persistedLabel)

        try presetStore.mergeAndSave(newPresets)
        customLinkLabelPresets = presetStore.load()
    }
}
