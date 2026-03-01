//
//  ContentView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedView") var selectedView: String?
    @State private var viewModel = ContentViewModel()

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
        .task {
            viewModel.seedIfNeeded(modelContext: modelContext)
        }
    }
}

@MainActor
@Observable
final class ContentViewModel {
    private(set) var hasSeededSampleData = false

    func seedIfNeeded(modelContext: ModelContext) {
        guard !hasSeededSampleData else { return }
        SampleData.seedIfNeeded(in: modelContext)
        hasSeededSampleData = true
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.previewContainer)
}
