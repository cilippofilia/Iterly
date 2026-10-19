//
//  ProjectsListView.swift
//  Iterly
//

import SwiftData
import SwiftUI
import IterlyCore

/// Sidebar column of the Projects split view. Rows drive `selection`.
struct ProjectsListView: View {
    let projects: [Project]
    @Binding var selection: Project?

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = ProjectViewModel()
    @State private var projectsViewModel = ProjectsViewModel()
    @State private var projectPendingDeletion: Project?
    @State private var showDeletionAlert: Bool = false
    @State private var showPinLimitAlert: Bool = false
    @State private var errorMessage: String?
    @State private var showAddProjectSheet: Bool = false

    private let orderedStatuses: [TaskStatus] = [.blocked, .inProgress, .done, .notStarted]

    var body: some View {
        Group {
            if projects.isEmpty {
                UnavailableProjectsView()
            } else {
                let split = projectsViewModel.splitProjects(projects)
                List(selection: $selection) {
                    if !split.active.isEmpty {
                        Section {
                            ForEach(split.active) { project in
                                row(for: project)
                            }
                        }
                    }

                    if !split.closed.isEmpty {
                        Section("Closed Projects") {
                            ForEach(split.closed) { project in
                                row(for: project)
                                    .opacity(0.6)
                            }
                        }
                    }
                }
                .platformInsetGroupedListStyle()
            }
        }
        .platformListRowSpacing(8)
        .navigationTitle("Projects")
        .safeAreaInset(edge: .bottom) {
            VStack {
                if !projects.isEmpty {
                    ProjectsLegendView(orderedStatuses: orderedStatuses)
                }
                CrossPromoBannerView()
            }
        }
        .alert("Delete Project?", isPresented: $showDeletionAlert, actions: {
            Button("Delete", role: .destructive) {
                guard let project = projectPendingDeletion else { return }
                // Deferred so a failure alert is set after this confirmation alert dismisses.
                Task { deleteProject(project) }
            }
            Button("Cancel", role: .cancel) {
                projectPendingDeletion = nil
            }
        }, message: {
            Text("This will permanently remove the project and its tasks.")
        })
        .alert("Something Went Wrong", item: $errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: {
            Text($0)
        }
        .alert("Can't Pin Project", isPresented: $showPinLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Only 4 projects can be pinned at the same time.")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Project", systemImage: "plus") {
                    showAddProjectSheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .sheet(isPresented: $showAddProjectSheet) {
            NavigationStack {
                ProjectFormView()
            }
        }
    }

    private func row(for project: Project) -> some View {
        ProjectRowLinkView(
            project: project,
            onTogglePin: { togglePin(project) },
            onDelete: {
                projectPendingDeletion = project
                showDeletionAlert = true
            }
        )
    }

    private func deleteProject(_ project: Project) {
        let wasSelected = selection?.id == project.id
        do {
            try viewModel.deleteProject(project, modelContext: modelContext)
            // The detail view is gated on the stored projects, so clearing after deletion is safe.
            if wasSelected {
                selection = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        projectPendingDeletion = nil
        showDeletionAlert = false
    }

    private func togglePin(_ project: Project) {
        do {
            if try viewModel.togglePin(project: project, modelContext: modelContext) == .limitReached {
                showPinLimitAlert = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
