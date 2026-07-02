//
//  SharedModelContainer.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation
import SwiftData

/// Single source of truth for the SwiftData schema/configuration shared by the app
/// and the IterlyWidgets extension, both of which must open the same App Group store.
public enum SharedModelContainer {
    public static let groupIdentifier = "group.cilia.filippo.Iterly"

    public static func make() -> ModelContainer {
        migrateLegacyStoreIfNeeded()

        let schema = Schema([Project.self, ProjectTask.self, TaskAttachment.self, ProjectRelease.self, ProjectLink.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(groupIdentifier)
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }

    /// Existing installs keep their store in the app's default (non-group) Application Support
    /// directory. The first time the App Group store is opened, copy that data over so it isn't
    /// orphaned by the switch to `groupContainer`.
    private static func migrateLegacyStoreIfNeeded() {
        let fileManager = FileManager.default
        let storeFileName = "default.store"

        guard let groupContainerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
            return
        }

        let groupStoreDirectory = groupContainerURL.appending(path: "Library/Application Support", directoryHint: .isDirectory)
        let legacyStoreDirectory = URL.applicationSupportDirectory

        let groupStoreURL = groupStoreDirectory.appending(path: storeFileName)
        let legacyStoreURL = legacyStoreDirectory.appending(path: storeFileName)

        guard !fileManager.fileExists(atPath: groupStoreURL.path),
              fileManager.fileExists(atPath: legacyStoreURL.path) else {
            return
        }

        try? fileManager.createDirectory(at: groupStoreDirectory, withIntermediateDirectories: true)

        for suffix in ["", "-wal", "-shm"] {
            let source = legacyStoreDirectory.appending(path: storeFileName + suffix)
            let destination = groupStoreDirectory.appending(path: storeFileName + suffix)
            guard fileManager.fileExists(atPath: source.path) else { continue }
            try? fileManager.copyItem(at: source, to: destination)
        }
    }
}
