//
//  HomeView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    static let homeTag: String? = "Home"

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProjectViewModel()
    @State private var homeViewModel = HomeViewModel()
    @State private var showEraseDataAlert: Bool = false
    @State private var showAddDataAlert: Bool = false

    @Query(
        filter: #Predicate<Project> { $0.isPinned == true },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var pinnedProjects: [Project]

    @Query(
        filter: #Predicate<Project> { $0.isPinned == false },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var projects: [Project]

    @Query
    private var tasks: [ProjectTask]

    var body: some View {
        NavigationStack {
            HomeContentView(
                pinnedProjects: pinnedProjects,
                projects: projects,
                tasks: tasks,
                viewModel: homeViewModel
            )
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HomeToolbarButtonsView(
                        showEraseDataAlert: $showEraseDataAlert,
                        showAddDataAlert: $showAddDataAlert
                    )
                }
            }
            .alert("Erase All Data?", isPresented: $showEraseDataAlert) {
                Button("Erase Data", role: .destructive) {
                    viewModel.eraseAllData(modelContext: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all projects, tasks, and releases.")
            }
            .alert("Add Sample Data?", isPresented: $showAddDataAlert) {
                Button("Add Data") {
                    viewModel.addSampleData(modelContext: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Sample data will be added to your current projects.")
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(SampleData.makePreviewContainer())
}
