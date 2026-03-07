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

    @Query(sort: \Project.creationDate, order: .reverse)
    private var projects: [Project]

    let orderedStatuses: [TaskStatus] = [.blocked, .inProgress, .done, .notStarted]

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    UnavailableProjectsView()
                } else {
                    List(projects) { project in
                        NavigationLink(value: project) {
                            ProjectRowView(
                                title: project.title,
                                tasks: project.tasks ?? [],
                                blockedAmount: project.blockedAmount,
                                inProgressAmount: project.inProgressAmount,
                                doneAmount: project.doneAmount
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(action: {
                                    project.isPinned.toggle()
                                }) {
                                    Label("Pin", systemImage: "pin")
                                }
                                Button(role: .destructive, action: {
                                    modelContext.delete(project)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.insetGrouped)
                    .contentMargins(.bottom, 70, for: .scrollContent)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .listRowSpacing(8)
            .navigationTitle("Projects")
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    createProjectButton
                }
            }
            .overlay(alignment: .bottom) {
                if !projects.isEmpty {
                    HStack(spacing: .zero) {
                        ForEach(orderedStatuses, id: \.self) { status in
                            Circle().fill(status.backgroundColor)
                                .frame(width: 6, height: 6)
                                .padding(.trailing, 2)
                            Text(status.title)
                                .font(.caption2)
                                .padding(.trailing, 8)
                        }
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
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
                viewModel.createProject(modelContext: modelContext)
            }
        )
    }
}

#Preview("Light") {
    TabView {
        ProjectsView()
            .modelContainer(SampleData.previewContainer)
    }
}
#Preview("Dark") {
    TabView {
        ProjectsView()
            .modelContainer(SampleData.previewContainer)
            .preferredColorScheme(.dark)
    }
}
#Preview("Dark - no projects") {
    TabView {
        ProjectsView()
            .modelContainer(SampleData.emptyPreviewContainer)
            .preferredColorScheme(.dark)
    }
}
