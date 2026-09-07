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
    @State private var removeAdsStore = RemoveAdsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 600)
                #endif
                .modelContainer(Self.modelContainer)
                .environment(crossPromoSignal)
                .environment(removeAdsStore)
        }
        #if os(macOS)
        .defaultSize(width: 1100, height: 750)
        #endif

        #if os(macOS)
        // Standard Cmd+, window. The Settings tab stays in the sidebar too, for
        // parity with iOS and discoverability.
        Settings {
            SettingsView()
                .frame(minWidth: 500, minHeight: 500)
                .modelContainer(Self.modelContainer)
                .environment(crossPromoSignal)
                .environment(removeAdsStore)
        }
        #endif
    }
}
