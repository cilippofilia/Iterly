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

    @Query(
        filter: #Predicate<Project> { $0.isPinned == false },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var projects: [Project]
    
    @Query(sort: \ProjectTask.dueDate, order: .reverse)
    private var tasks: [ProjectTask]

    var body: some View {
        NavigationStack {
            Group {
                if pinnedProjects.isEmpty, projects.isEmpty, tasks.isEmpty {
                    unavailableView
                } else {
                    availableView
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    #if DEBUG
                    ereaseAllDataButton
                    addSampleDataButton
                    #else
                    // TODO: Create project button
                    #endif
                }
            }
        }
    }
}

extension HomeView {
    private var unavailableView: some View {
        ContentUnavailableView {
            Label("No projects found", systemImage: "folder.badge.questionmark")
        } description: {
            Text("There are no active projects at the moment. Create one to get started.")
        } actions: {
            #if DEBUG
            addSampleDataButton
            #else
            // TODO: Create project button
            #endif
        }
    }

    private var availableView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                PinnedProjectsSection(projects: pinnedProjects)
                    .padding(.bottom)

                ProjectsSection(projects: Array(projects.prefix(5)))
                    .padding(.bottom)

                TasksSection(tasks: Array(tasks.prefix(5)))
                    .padding(.bottom)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationDestination(for: HomeDestination.self) { destination in
            switch destination {
            case .project:
                ProjectPlaceholderView(title: "Test Project")
            case .task:
                TaskPlaceholderView(title: "Test Task")
            }
        }
        .contentMargins(.bottom, 70, for: .scrollContent)
    }

    var addSampleDataButton: some View {
        Button(
            "Add Data",
            systemImage: "plus",
            action: {
                viewModel.addSampleData(modelContext: modelContext)
            }
        )
    }
    var ereaseAllDataButton: some View {
        Button(
            "Erase Data",
            systemImage: "trash",
            role: .destructive,
            action: {
                viewModel.eraseAllData(modelContext: modelContext)
            }
        )
    }
}

enum HomeDestination: Hashable {
    case project
    case task
}

#Preview {
    HomeView()
        .modelContainer(SampleData.previewContainer)
}
