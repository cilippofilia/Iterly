//
//  ProjectsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct ProjectsView: View {
    static let projectsTag: String? = "Projects"

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = ProjectViewModel()
    @State private var projectsViewModel = ProjectsViewModel()
    @State private var projectPendingDeletion: Project?
    @State private var showDeletionAlert: Bool = false
    @State private var showPinLimitAlert: Bool = false
    @State private var showAddProjectSheet: Bool = false

    @Query(sort: [
        SortDescriptor(\Project.lastUpdated, order: .reverse),
        SortDescriptor(\Project.creationDate, order: .reverse)
    ])
    private var projects: [Project]

    private let orderedStatuses: [TaskStatus] = [.blocked, .inProgress, .done, .notStarted]

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    UnavailableProjectsView()
                } else {
                    let split = projectsViewModel.splitProjects(projects)
                    List {
                        // active projects
                        if !split.active.isEmpty {
                            Section {
                                ForEach(split.active) { project in
                                    ProjectRowLinkView(
                                        project: project,
                                        onTogglePin: {
                                            if viewModel.togglePin(project: project, modelContext: modelContext) == false {
                                                showPinLimitAlert = true
                                            }
                                        },
                                        onDelete: {
                                            projectPendingDeletion = project
                                            showDeletionAlert = true
                                        }
                                    )
                                }
                            }
                        }

                        // closed projects
                        if !split.closed.isEmpty {
                            Section("Closed Projects") {
                                ForEach(split.closed) { project in
                                    ProjectRowLinkView(
                                        project: project,
                                        onTogglePin: {
                                            if viewModel.togglePin(project: project, modelContext: modelContext) == false {
                                                showPinLimitAlert = true
                                            }
                                        },
                                        onDelete: {
                                            projectPendingDeletion = project
                                            showDeletionAlert = true
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .contentMargins(.bottom, 70, for: .scrollContent)
                }
            }
            .listRowSpacing(8)
            .navigationTitle("Projects")
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .alert("Delete Project?", isPresented: $showDeletionAlert, actions: {
                Button("Delete", role: .destructive) {
                    guard let project = projectPendingDeletion else { return }
                    deleteProject(project)
                }
                Button("Cancel", role: .cancel) {
                    projectPendingDeletion = nil
                }
            }, message: {
                Text("This will permanently remove the project and its tasks.")
            })
            .alert("Can't Pin Project", isPresented: $showPinLimitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Only 4 projects can be pinned at the same time.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    createProjectButton
                }
            }
            .sheet(isPresented: $showAddProjectSheet) {
                NavigationStack {
                    ProjectFormView()
                }
            }
            .overlay(alignment: .bottom) {
                if !projects.isEmpty {
                    ProjectsLegendView(orderedStatuses: orderedStatuses)
                }
            }
        }
    }

    var createProjectButton: some View {
        Button(
            "Add Project",
            systemImage: "plus",
            action: {
                showAddProjectSheet = true
            }
        )
    }

    private func deleteProject(_ project: Project) {
        viewModel.deleteProject(project, modelContext: modelContext)
        projectPendingDeletion = nil
        showDeletionAlert = false
    }
}

#Preview("Light") {
    ProjectsView()
        .modelContainer(SampleData.makePreviewContainer())
}
#Preview("Dark") {
    ProjectsView()
        .modelContainer(SampleData.makePreviewContainer())
        .preferredColorScheme(.dark)
}
