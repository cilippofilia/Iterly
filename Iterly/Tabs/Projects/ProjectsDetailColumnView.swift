//
//  ProjectsDetailColumnView.swift
//  Iterly
//

import SwiftUI
import IterlyCore

/// Detail column of the Projects split view: the selected project, or a placeholder.
struct ProjectsDetailColumnView: View {
    let projects: [Project]
    let selectedProject: Project?
    @Binding var path: NavigationPath
    let onDelete: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let project = ProjectSelection.validated(selectedProject, in: projects) {
                    ProjectDetailView(project: project, onDelete: onDelete)
                } else {
                    ContentUnavailableView("Select a Project", systemImage: "folder")
                }
            }
            .appNavigationDestinations(onProjectDelete: onDelete)
            .id(selectedProject?.id)
        }
    }
}
