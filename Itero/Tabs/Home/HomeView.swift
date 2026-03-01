//
//  HomeView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import CoreSpotlight
import SwiftData
import SwiftUI

struct HomeView: View {
    static let homeTag: String? = "Home"

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()

    @Query(
        filter: #Predicate<Project> { $0.isPinned == true },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var pinnedProjects: [Project]

    @Query(sort: \Project.creationDate, order: .reverse)
    private var projects: [Project]

    @Query(sort: \ProjectTask.creationDate, order: .reverse)
    private var tasks: [ProjectTask]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    PinnedProjectsSection(projects: pinnedProjects)
                    ProjectsSection(projects: Array(projects.prefix(5)))
                    TasksSection(tasks: Array(tasks.prefix(5)))
                }
            }
            .navigationTitle("Home")
            .toolbar {
                Button(
                    "Add Data",
                    systemImage: "plus",
                    action: {
                        viewModel.addSampleData(modelContext: modelContext)
                    }
                )
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .project(let id):
                    ProjectPlaceholderView(projectID: id)
                case .task(let id):
                    TaskPlaceholderView(taskID: id)
                }
            }
            .contentMargins(.bottom, 70, for: .scrollContent)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(SampleData.previewContainer)
}
