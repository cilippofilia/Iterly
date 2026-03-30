//
//  HomeAvailableView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftData
import SwiftUI

@MainActor
struct HomeAvailableView: View {
    @AppStorage("selectedView") private var selectedView: String?
    @State private var activityViewModel = ActivityOverviewViewModel()

    let pinnedProjects: [Project]
    let projects: [Project]
    let allTasks: [ProjectTask]
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

                ActivityOverviewSectionView(
                    viewModel: activityViewModel,
                    cornerRadius: AppCornerRadius.regular,
                    isHeatmapInteractive: false,
                    trailingAction: {
                        selectedView = ActivityView.activityTag
                    }
                )
                .padding(.horizontal)
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
        .contentMargins(.bottom, 70, for: .scrollContent)
        .onChange(of: activityReloadToken, initial: true) { _, _ in
            activityViewModel.reload(projects: pinnedProjects + projects, tasks: allTasks)
        }
    }

    private var activityReloadToken: String {
        let projectToken = (pinnedProjects + projects)
            .map { project in
                "\(project.id.uuidString)-\(project.lastUpdated.timeIntervalSinceReferenceDate)"
            }
            .joined(separator: ",")
        let taskToken = allTasks
            .map { task in
                "\(task.id.uuidString)-\(task.creationDate.timeIntervalSinceReferenceDate)-\(task.lastUpdated?.timeIntervalSinceReferenceDate ?? 0)"
            }
            .joined(separator: ",")

        return [activityViewModel.selectedRange.rawValue, projectToken, taskToken].joined(separator: "|")
    }
}

#Preview {
    let projects = SampleData.makeProjects()
    let pinnedProjects = projects.filter(\.isPinned)
    let otherProjects = projects.filter { $0.isPinned == false }
    let homeViewModel = HomeViewModel()
    let totalProjectsCount = homeViewModel.totalProjectsCount(
        pinned: pinnedProjects,
        projects: otherProjects
    )

    NavigationStack {
        HomeAvailableView(
            pinnedProjects: pinnedProjects,
            projects: otherProjects,
            allTasks: projects.flatMap { $0.tasks ?? [] },
            upcomingTasks: homeViewModel.upcomingTasks(from: projects.flatMap(\.topLevelTasks)),
            totalProjectsCount: totalProjectsCount,
            showMore: totalProjectsCount > 5
        )
        .navigationTitle("Home")
    }
    .modelContainer(SampleData.makePreviewContainer())
}
