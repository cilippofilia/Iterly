//
//  HomeContentView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI
import IterlyCore

struct HomeContentView: View {
    let pinnedProjects: [Project]
    let projects: [Project]
    let tasks: [ProjectTask]
    let viewModel: HomeViewModel

    var body: some View {
        if pinnedProjects.isEmpty, projects.isEmpty, tasks.isEmpty {
            UnavailableProjectsView()
        } else {
            let activePinnedProjects = viewModel.activeProjects(from: pinnedProjects)
            let activeProjects = viewModel.activeProjects(from: projects)
            let upcomingTasks = viewModel.upcomingTasks(from: tasks)
            let totalProjectsCount = viewModel.totalProjectsCount(
                pinned: activePinnedProjects,
                projects: activeProjects
            )
            let showMore = totalProjectsCount > 5

            HomeAvailableView(
                pinnedProjects: activePinnedProjects,
                projects: activeProjects,
                allProjects: pinnedProjects + projects,
                allTasks: tasks,
                upcomingTasks: upcomingTasks,
                totalProjectsCount: totalProjectsCount,
                showMore: showMore
            )
        }
    }
}
