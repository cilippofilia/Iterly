//
//  IterlyApp.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

@main
struct IterlyApp: App {
    private static let modelContainer: ModelContainer = SharedModelContainer.make()

    @State private var crossPromoSignal = CrossPromoSignal()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Self.modelContainer)
                .environment(crossPromoSignal)
        }
    }
}
