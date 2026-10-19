//
//  ProjectsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct ProjectsView: View {
    @State private var selectedProject: Project?
    @State private var path = NavigationPath()

    @Query(sort: [
        SortDescriptor(\Project.lastUpdated, order: .reverse),
        SortDescriptor(\Project.creationDate, order: .reverse)
    ])
    private var projects: [Project]

    var body: some View {
        NavigationSplitView {
            ProjectsListView(projects: projects, selection: $selectedProject)
        } detail: {
            NavigationStack(path: $path) {
                Group {
                    if let project = ProjectSelection.validated(selectedProject, in: projects) {
                        ProjectDetailView(project: project, onDelete: clearSelection)
                    } else {
                        ContentUnavailableView("Select a Project", systemImage: "folder")
                    }
                }
                .appNavigationDestinations(onProjectDelete: clearSelection)
                .id(selectedProject?.id)
            }
        }
        .onChange(of: projects.map(\.id)) {
            selectedProject = ProjectSelection.validated(selectedProject, in: projects)
        }
        .onChange(of: selectedProject) {
            // A new selection starts at the project root.
            path = NavigationPath()
        }
    }

    private func clearSelection() {
        selectedProject = nil
        path = NavigationPath()
    }
}

#Preview {
    ProjectsView()
        .modelContainer(SampleData.makePreviewContainer())
}
