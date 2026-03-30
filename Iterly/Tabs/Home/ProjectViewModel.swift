import Foundation
import SwiftData

@MainActor
@Observable
final class ProjectViewModel {
    private let maxPinnedProjects = 4
    private let appStoreLookupService = AppStoreLookupService()

    func createProject(
        title: String,
        details: String,
        note: String,
        type: ProjectType,
        priority: ProjectPriority,
        status: ProjectStatus,
        isPinned: Bool,
        version: String,
        appStoreURL: String,
        modelContext: ModelContext
    ) async throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAppStoreURL = appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines)

        let project = Project(
            title: trimmedTitle,
            details: trimmedDetails.isEmpty ? nil : trimmedDetails,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            projectType: type,
            projectPriority: priority,
            projectStatus: status,
            creationDate: .now,
            lastUpdated: .now,
            isPinned: isPinned
        )

        let release = ProjectRelease(version: version, appStoreURL: trimmedAppStoreURL, project: project)
        project.currentRelease = release

        if trimmedAppStoreURL.isEmpty == false {
            let lookupResult = try await appStoreLookupService.lookup(appID: trimmedAppStoreURL)
            applyLookupResult(lookupResult, to: release)
        }

        modelContext.insert(project)

        try modelContext.save()
    }

    func updateProject(
        _ project: Project,
        title: String,
        details: String,
        note: String,
        type: ProjectType,
        priority: ProjectPriority,
        status: ProjectStatus,
        isPinned: Bool,
        version: String,
        appStoreURL: String,
        modelContext: ModelContext
    ) async throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAppStoreURL = appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines)
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
        project.type = type
        project.priority = priority
        project.status = status
        project.isPinned = isPinned
        project.touch()

        let release = ensureRelease(
            for: project,
            version: version,
            appStoreURL: trimmedAppStoreURL,
            modelContext: modelContext
        )

        if trimmedAppStoreURL.isEmpty {
            if previousAppStoreURL.isEmpty == false {
                disconnectAppStoreRelease(for: release, preservingVersion: version)
            }
            try modelContext.save()
            return
        }

        if let lookupResult {
            applyLookupResult(lookupResult, to: release)
            project.touch()
            try modelContext.save()
            return
        }

        try modelContext.save()
    }

    func togglePin(project: Project, modelContext: ModelContext) -> Bool {
        do {
            if project.isPinned == false {
                let descriptor = FetchDescriptor<Project>(
                    predicate: #Predicate<Project> { $0.isPinned == true }
                )
                let pinnedCount = try modelContext.fetchCount(descriptor)
                if pinnedCount >= maxPinnedProjects {
                    return false
                }
            }

            project.isPinned.toggle()
            project.touch()

            try modelContext.save()
            return true
        } catch {
            assertionFailure("Failed to toggle pin: \(error)")
            return false
        }
    }

    func deleteProject(_ project: Project, modelContext: ModelContext) {
        if let release = project.currentRelease {
            modelContext.delete(release)
        }
        modelContext.delete(project)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete project: \(error)")
        }
    }

    func refreshAppStoreRelease(for project: Project, modelContext: ModelContext) async throws {
        let release = try release(for: project)
        let lookupResult = try await appStoreLookupService.lookup(appID: release.appStoreURL)
        applyLookupResult(lookupResult, to: release)
        project.touch()
        try modelContext.save()
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
        try modelContext.save()
    }

    func disconnectAppStoreRelease(for project: Project, modelContext: ModelContext) throws {
        let release = try release(for: project)
        disconnectAppStoreRelease(for: release, preservingVersion: release.version)
        project.touch()
        try modelContext.save()
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

    func disconnectAllAppStoreLinks(modelContext: ModelContext) throws {
        for project in linkedProjects(modelContext: modelContext) {
            guard let release = project.currentRelease else { continue }
            disconnectAppStoreRelease(for: release, preservingVersion: release.version)
            project.touch()
        }

        try modelContext.save()
    }

    func eraseAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: ProjectTask.self)
            try modelContext.delete(model: ProjectRelease.self)
            try modelContext.delete(model: Project.self)

            try modelContext.save()
        } catch {
            assertionFailure("Failed to erase data: \(error)")
        }
    }

    func saveAppStoreSyncError(
        _ error: any Error,
        for project: Project,
        modelContext: ModelContext
    ) {
        project.currentRelease?.appStoreSyncError = error.localizedDescription

        do {
            try modelContext.save()
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

        let release = ProjectRelease(version: version, appStoreURL: appStoreURL, project: project)
        project.currentRelease = release
        modelContext.insert(release)
        return release
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
