//
//  DashboardAvailableView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

@MainActor
struct DashboardAvailableView: View {
    @Environment(TabSelection.self) private var tabSelection
    @State private var activityViewModel = ActivityOverviewViewModel()

    let pinnedProjects: [Project]
    let projects: [Project]
    /// Every project, including closed ones, so the activity overview
    /// matches the Activity tab while the sections above show active only.
    let allProjects: [Project]
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
                    isDashboardView: true,
                    cornerRadius: AppCornerRadius.regular,
                    isHeatmapInteractive: false,
                    trailingAction: {
                        tabSelection.selected = .activity
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
            .readableContentWidth()
        }
        .appNavigationDestinations()
        .onChange(of: activityReloadKey, initial: true) { _, _ in
            activityViewModel.reload(projects: allProjects, tasks: allTasks)
        }
    }

    private var activityReloadKey: Int {
        ActivityReloadKey.make(range: activityViewModel.selectedRange, projects: allProjects, tasks: allTasks)
    }
}

#Preview {
    let projects = SampleData.makeProjects()
    let pinnedProjects = projects.filter(\.isPinned)
    let otherProjects = projects.filter { $0.isPinned == false }
    let dashboardViewModel = DashboardViewModel()
    let totalProjectsCount = dashboardViewModel.totalProjectsCount(
        pinned: pinnedProjects,
        projects: otherProjects
    )

    NavigationStack {
        DashboardAvailableView(
            pinnedProjects: pinnedProjects,
            projects: otherProjects,
            allProjects: projects,
            allTasks: projects.flatMap { $0.tasks ?? [] },
            upcomingTasks: dashboardViewModel.upcomingTasks(from: projects.flatMap(\.topLevelTasks)),
            totalProjectsCount: totalProjectsCount,
            showMore: totalProjectsCount > 5
        )
        .navigationTitle("Dashboard")
    }
    .modelContainer(SampleData.makePreviewContainer())
    .environment(TabSelection())
}
