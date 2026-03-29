//
//  HomeAvailableView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct HomeAvailableView: View {
    let pinnedProjects: [Project]
    let projects: [Project]
    let upcomingTasks: [ProjectTask]
    let totalProjectsCount: Int
    let showMore: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                PinnedProjectsSection(projects: pinnedProjects)
                    .padding(.bottom)

                ProjectsSection(
                    projects: Array(projects.prefix(5)),
                    allProjectsCount: totalProjectsCount,
                    showMore: showMore
                )
                .padding(.bottom)

                TasksSection(
                    title: "Upcoming tasks",
                    tasks: Array(upcomingTasks.prefix(10))
                )
                .padding(.bottom)
            }
        }
        .navigationDestination(for: Project.self) { project in
            ProjectDetailView(project: project)
        }
        .navigationDestination(for: UUID.self) { taskId in
            if let task = upcomingTasks.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
        .contentMargins(.bottom, 70, for: .scrollContent)
    }
}
