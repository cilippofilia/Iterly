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

    #if os(iOS)
    @Environment(\.tabBarPlacement) private var tabBarPlacement
    #endif

    var body: some View {
        Group {
            #if os(macOS)
            // A NavigationSplitView nested in the sidebar TabView gets a bogus leading safe-area
            // inset on macOS that pushes the detail off-screen and hides the bottom banner.
            HSplitView {
                ProjectsListView(projects: projects, selection: $selectedProject)
                    // Wide enough that titles, status badges and the legend don't wrap or truncate.
                    // HSplitView doesn't stretch its panes vertically, so each one fills the height itself.
                    .frame(minWidth: 320, idealWidth: 360, maxWidth: 480, maxHeight: .infinity)

                ProjectsDetailColumnView(
                    projects: projects,
                    selectedProject: selectedProject,
                    path: $path,
                    onDelete: clearSelection
                )
                .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
            }
            #else
            if tabBarPlacement == .bottomBar {
                // A split view nested in a tab sidebar (iPhone Duo inner display) shows its own toggle
                // in place of the tab sidebar's, stranding the other tabs; a plain stack keeps it.
                // Duo reports `.bottomBar` there even though tabs show as a sidebar. iPad (`.topBar`
                // or `.sidebar`) keeps the split view.
                NavigationStack(path: $path) {
                    // No selection: a selectable List would also select on tap, and rows must only push.
                    ProjectsListView(projects: projects, selection: nil)
                        .appNavigationDestinations(onProjectDelete: clearSelection)
                }
            } else {
                NavigationSplitView {
                    ProjectsListView(projects: projects, selection: $selectedProject)
                        .navigationSplitViewColumnWidth(min: 320, ideal: 360, max: 480)
                } detail: {
                    ProjectsDetailColumnView(
                        projects: projects,
                        selectedProject: selectedProject,
                        path: $path,
                        onDelete: clearSelection
                    )
                }
            }
            #endif
        }
        #if os(iOS)
        // The two layouts use `path` differently (project pushes vs. pushes within a project).
        .onChange(of: tabBarPlacement) { clearSelection() }
        #endif
        // Set on the container so macOS shows "Projects" in the column header instead of the app name.
        .navigationTitle("Projects")
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
        .environment(RemoveAdsStore())
}
