//
//  ContentView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedView") var selectedView: String?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $selectedView) {
            Tab("Home", systemImage: "house", value: HomeView.homeTag) {
                HomeView()
            }

            Tab("Projects", systemImage: "folder", value: ProjectsView.projectsTag) {
                ProjectsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.makePreviewContainer())
}
