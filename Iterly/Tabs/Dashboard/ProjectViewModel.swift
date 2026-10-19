import Foundation
import SwiftData
import IterlyCore

@MainActor
@Observable
final class ProjectViewModel {
    private let maxPinnedProjects = 4
    private let appStoreLookupService = AppStoreLookupService()

    func createProject(_ input: ProjectInput, modelContext: ModelContext) async throws {
        let trimmedTitle = input.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = input.details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = input.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAppStoreURL = input.appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines)

        let project = Project(
            title: trimmedTitle,
            details: trimmedDetails.isEmpty ? nil : trimmedDetails,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            projectType: input.type,
            projectPriority: input.priority,
            projectStatus: input.status,
            creationDate: .now,
            lastUpdated: .now,
            isPinned: input.isPinned
        )

        let release = ProjectRelease(
            version: input.version,
            appStoreURL: trimmedAppStoreURL,
            project: project
        )
        project.currentRelease = release
        release.links = makeUsefulLinks(from: input.usefulLinks, release: release)

        if trimmedAppStoreURL.isEmpty == false {
            let lookupResult = try await appStoreLookupService.lookup(appID: trimmedAppStoreURL)
            applyLookupResult(lookupResult, to: release)
        }

        modelContext.insert(project)

        try modelContext.saveAndReloadActivityWidget()
    }

    func updateProject(
        _ project: Project,
        with input: ProjectInput,
        modelContext: ModelContext
    ) async throws {
        let trimmedTitle = input.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = input.details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = input.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAppStoreURL = input.appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let previousAppStoreURL = project.currentRelease?.appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let previousAppStoreAppID = project.currentRelease?.extractedAppStoreAppID ?? ""
        let nextAppStoreAppID = trimmedAppStoreURL.isEmpty
            ? ""
            : try appStoreLookupService.extractedAppID(from: trimmedAppStoreURL)
        let needsRelink = trimmedAppStoreURL.isEmpty == false && previousAppStoreAppID != nextAppStoreAppID
        let lookupResult = needsRelink
            ? try await appStoreLookupService.lookup(appID: trimmedAppStoreURL)
            : nil

        project.title = trimmedTitle
        project.details = trimmedDetails.isEmpty ? nil : trimmedDetails
        project.note = trimmedNote.isEmpty ? nil : trimmedNote
        project.type = input.type
        project.priority = input.priority
        project.status = input.status
        project.isPinned = input.isPinned
        project.touch()

        let release = ensureRelease(
            for: project,
            version: input.version,
            appStoreURL: trimmedAppStoreURL,
            modelContext: modelContext
        )
        replaceUsefulLinks(on: release, with: input.usefulLinks, modelContext: modelContext)

        if trimmedAppStoreURL.isEmpty {
            if previousAppStoreURL.isEmpty == false {
                disconnectAppStoreRelease(for: release, preservingVersion: input.version)
            }
            try modelContext.saveAndReloadActivityWidget()
            return
        }

        if let lookupResult {
            applyLookupResult(lookupResult, to: release)
            project.touch()
            try modelContext.saveAndReloadActivityWidget()
            return
        }

        try modelContext.saveAndReloadActivityWidget()
    }

    func togglePin(project: Project, modelContext: ModelContext) throws -> PinToggleResult {
        if project.isPinned == false {
            let descriptor = FetchDescriptor<Project>(
                predicate: #Predicate<Project> { $0.isPinned == true }
            )
            let pinnedCount = try modelContext.fetchCount(descriptor)
            if pinnedCount >= maxPinnedProjects {
                return .limitReached
            }
        }

        project.isPinned.toggle()
        project.touch()

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            // rollback() discards all unsaved changes in the context, not just this one.
            modelContext.rollback()
            throw error
        }
        return .toggled
    }

    func deleteProject(_ project: Project, modelContext: ModelContext) throws {
        if let release = project.currentRelease {
            modelContext.delete(release)
        }
        modelContext.delete(project)

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            // rollback() discards all unsaved changes in the context, not just this one.
            modelContext.rollback()
            throw error
        }
    }

    func refreshAppStoreRelease(for project: Project, modelContext: ModelContext) async throws {
        let release = try release(for: project)
        let lookupResult = try await appStoreLookupService.lookup(appID: release.appStoreURL)
        applyLookupResult(lookupResult, to: release)
        project.touch()
        try modelContext.saveAndReloadActivityWidget()
    }

    func linkAppStoreRelease(
        for project: Project,
        appStoreURL: String,
        modelContext: ModelContext
    ) async throws {
        let release = try release(for: project)
        let lookupResult = try await appStoreLookupService.lookup(appID: appStoreURL)
        applyLookupResult(lookupResult, to: release)
        project.touch()
        try modelContext.saveAndReloadActivityWidget()
    }

    func disconnectAppStoreRelease(for project: Project, modelContext: ModelContext) throws {
        let release = try release(for: project)
        disconnectAppStoreRelease(for: release, preservingVersion: release.version)
        project.touch()
        try modelContext.saveAndReloadActivityWidget()
    }

    func linkedProjects(modelContext: ModelContext) -> [Project] {
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\Project.lastUpdated, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor).filter {
                $0.currentRelease?.hasAppStoreLink == true
            }
        } catch {
            assertionFailure("Failed to fetch linked projects: \(error)")
            return []
        }
    }

    func projectsWithUsefulLinks(modelContext: ModelContext) -> [Project] {
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\Project.lastUpdated, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor).filter {
                $0.currentRelease?.hasUsefulLinks == true
            }
        } catch {
            assertionFailure("Failed to fetch useful-link projects: \(error)")
            return []
        }
    }

    func disconnectAllAppStoreLinks(modelContext: ModelContext) throws {
        for project in linkedProjects(modelContext: modelContext) {
            guard let release = project.currentRelease else { continue }
            disconnectAppStoreRelease(for: release, preservingVersion: release.version)
            project.touch()
        }

        try modelContext.saveAndReloadActivityWidget()
    }

    func disconnectUsefulLink(
        _ link: ProjectLink,
        from project: Project,
        modelContext: ModelContext
    ) throws {
        guard let release = project.currentRelease else {
            throw AppStoreSyncError.invalidResponse
        }

        release.links = release.usefulLinks.filter { $0.id != link.id }
        modelContext.delete(link)
        project.touch()
        try modelContext.saveAndReloadActivityWidget()
    }

    func disconnectAllUsefulLinks(modelContext: ModelContext) throws {
        for project in projectsWithUsefulLinks(modelContext: modelContext) {
            for link in project.currentRelease?.usefulLinks ?? [] {
                modelContext.delete(link)
            }
            project.currentRelease?.links = []
            project.touch()
        }

        try modelContext.saveAndReloadActivityWidget()
    }

    func disconnectAllLinks(modelContext: ModelContext) throws {
        for project in linkedProjects(modelContext: modelContext) {
            guard let release = project.currentRelease else { continue }
            disconnectAppStoreRelease(for: release, preservingVersion: release.version)
            project.touch()
        }

        for project in projectsWithUsefulLinks(modelContext: modelContext) {
            for link in project.currentRelease?.usefulLinks ?? [] {
                modelContext.delete(link)
            }
            project.currentRelease?.links = []
            project.touch()
        }

        try modelContext.saveAndReloadActivityWidget()
    }

    func eraseAllData(modelContext: ModelContext) throws {
        try modelContext.delete(model: ProjectTask.self)
        try modelContext.delete(model: ProjectRelease.self)
        try modelContext.delete(model: Project.self)

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            // rollback() discards all unsaved changes in the context, not just this one.
            modelContext.rollback()
            throw error
        }
    }

    func saveAppStoreSyncError(
        _ error: any Error,
        for project: Project,
        modelContext: ModelContext
    ) {
        project.currentRelease?.appStoreSyncError = error.localizedDescription

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            assertionFailure("Failed to save App Store sync error: \(error)")
        }
    }

    private func release(for project: Project) throws -> ProjectRelease {
        guard let release = project.currentRelease else {
            throw AppStoreSyncError.invalidResponse
        }
        return release
    }

    private func ensureRelease(
        for project: Project,
        version: String,
        appStoreURL: String,
        modelContext: ModelContext
    ) -> ProjectRelease {
        if let release = project.currentRelease {
            if release.hasAppStoreLink == false {
                release.version = version
            }
            release.build = ""
            release.appStoreURL = appStoreURL
            return release
        }

        let release = ProjectRelease(
            version: version,
            appStoreURL: appStoreURL,
            project: project
        )
        project.currentRelease = release
        modelContext.insert(release)
        return release
    }

    private func replaceUsefulLinks(
        on release: ProjectRelease,
        with inputs: [ProjectLinkInput],
        modelContext: ModelContext
    ) {
        for link in release.usefulLinks {
            modelContext.delete(link)
        }

        let newLinks = makeUsefulLinks(from: inputs, release: release)
        release.links = newLinks

        for link in newLinks {
            modelContext.insert(link)
        }
    }

    private func makeUsefulLinks(
        from inputs: [ProjectLinkInput],
        release: ProjectRelease
    ) -> [ProjectLink] {
        inputs.map { input in
            ProjectLink(
                kind: input.kind,
                label: input.label,
                url: input.url,
                sortOrder: input.sortOrder,
                projectRelease: release
            )
        }
    }

    private func disconnectAppStoreRelease(for release: ProjectRelease, preservingVersion version: String) {
        release.version = version
        release.build = ""
        release.appStoreURL = ""
        release.appStoreSyncDate = nil
        release.appStoreSyncError = nil
    }

    private func applyLookupResult(_ lookupResult: AppStoreLookupResult, to release: ProjectRelease) {
        release.version = lookupResult.version
        release.appStoreURL = lookupResult.storeURL
        release.build = ""
        release.appStoreSyncDate = .now
        release.appStoreSyncError = nil
    }
}
