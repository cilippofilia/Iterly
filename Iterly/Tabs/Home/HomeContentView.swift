//
//  HomeContentView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct HomeContentView: View {
    let pinnedProjects: [Project]
    let projects: [Project]
    let tasks: [ProjectTask]
    let viewModel: HomeViewModel

    var body: some View {
        if pinnedProjects.isEmpty, projects.isEmpty, tasks.isEmpty {
            UnavailableProjectsView()
        } else {
            let upcomingTasks = viewModel.upcomingTasks(from: tasks)
            let totalProjectsCount = viewModel.totalProjectsCount(
                pinned: pinnedProjects,
                projects: projects
            )
            let showMore = totalProjectsCount > 5

            HomeAvailableView(
                pinnedProjects: pinnedProjects,
                projects: projects,
                allTasks: tasks,
                upcomingTasks: upcomingTasks,
                totalProjectsCount: totalProjectsCount,
                showMore: showMore
            )
        }
    }
}
