//
//  ContentView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import CoreSpotlight
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedView") var selectedView: String?

    var body: some View {
        TabView(selection: $selectedView) {
            Tab("Home", systemImage: "house", value: HomeView.homeTag) {
                HomeView()
            }

            Tab("Open", systemImage: "list.bullet", value: ProjectsView.openTag) {
                ProjectsView()
            }

            Tab("Settings", systemImage: "gear", value: SettingsView.settingsTag) {
                SettingsView()
            }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
    }

    func moveToHome(_ input: Any) {
        selectedView = HomeView.homeTag
    }
}

#Preview {
    ContentView()
}
