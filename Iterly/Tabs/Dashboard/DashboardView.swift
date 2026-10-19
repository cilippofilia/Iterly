//
//  DashboardView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct DashboardView: View {
    @State private var dashboardViewModel = DashboardViewModel()

    @Query(
        filter: #Predicate<Project> { $0.isPinned == true },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var pinnedProjects: [Project]

    @Query(
        filter: #Predicate<Project> { $0.isPinned == false },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var projects: [Project]

    @Query
    private var tasks: [ProjectTask]

    var body: some View {
        NavigationStack {
            DashboardContentView(
                pinnedProjects: pinnedProjects,
                projects: projects,
                tasks: tasks,
                viewModel: dashboardViewModel
            )
            .navigationTitle("Dashboard")
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(SampleData.makePreviewContainer())
        .environment(CrossPromoSignal())
        .environment(TabSelection())
}
