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
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.insetGrouped)
                }
            }
//            .scrollBounceBehavior(.basedOnSize)
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
            .safeAreaInset(edge: .bottom) {
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
                    .padding(.bottom)
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
    ProjectsView()
        .modelContainer(SampleData.previewContainer)
}
#Preview("Dark") {
    ProjectsView()
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
