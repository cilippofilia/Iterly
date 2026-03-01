//
//  IteroApp.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

@main
struct IteroApp: App {
    private static let modelContainer: ModelContainer = {
        let schema = Schema([Project.self, ProjectTask.self])
        // TODO: change to false before release
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

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
