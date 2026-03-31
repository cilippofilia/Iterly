//
//  IterlyApp.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

@main
struct IterlyApp: App {
    private static let modelContainer: ModelContainer = {
        let schema = Schema([Project.self, ProjectTask.self, ProjectRelease.self, ProjectLink.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Self.modelContainer)
        }
    }
}
