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
    @State private var projectPendingDeletion: Project?
    @State private var showDeletionAlert: Bool = false
    @State private var showPinLimitAlert: Bool = false
    @State private var showAddProjectSheet: Bool = false

    @Query(sort: [
        SortDescriptor(\Project.lastUpdated, order: .reverse),
        SortDescriptor(\Project.creationDate, order: .reverse)
    ])
    private var projects: [Project]

    let orderedStatuses: [TaskStatus] = [.blocked, .inProgress, .done, .notStarted]

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    UnavailableProjectsView()
                } else {
                    List {
                        if !activeProjects.isEmpty {
                            Section {
                                ForEach(activeProjects) { project in
                                    projectRow(project)
                                }
                            }
                        }

                        if !closedProjects.isEmpty {
                            Section("Closed Projects") {
                                ForEach(closedProjects) { project in
                                    projectRow(project)
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
                    HStack(spacing: 8) {
                        ForEach(orderedStatuses, id: \.self) { status in
                            Circle().fill(status.backgroundColor)
                                .frame(width: 6, height: 6)
                            Text(status.title)
                                .font(.caption2)
                        }
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                    .padding(.bottom, 8)
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

    private var activeProjects: [Project] {
        projects.filter { $0.status != .closed }
    }

    private var closedProjects: [Project] {
        projects.filter { $0.status == .closed }
    }

    @ViewBuilder
    private func projectRow(_ project: Project) -> some View {
        NavigationLink(value: project) {
            ProjectRowView(
                title: project.title,
                statusTitle: project.status.title,
                statusColor: project.status.backgroundColor,
                currentRelease: project.currentRelease,
                tasks: project.topLevelTasks,
                blockedAmount: project.blockedAmount,
                inProgressAmount: project.inProgressAmount,
                doneAmount: project.doneAmount
            )
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: {
                    if viewModel.togglePin(project: project, modelContext: modelContext) == false {
                        showPinLimitAlert = true
                    }
                }) {
                    Label("Pin", systemImage: "pin")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: {
                    projectPendingDeletion = project
                    showDeletionAlert = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .buttonStyle(.plain)
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
