//
//  ActivityView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

@MainActor
struct ActivityView: View {
    @State private var viewModel = ActivityOverviewViewModel()

    @Query(sort: [
        SortDescriptor(\Project.lastUpdated, order: .reverse),
        SortDescriptor(\Project.creationDate, order: .reverse)
    ])
    private var projects: [Project]

    @Query(sort: \ProjectTask.creationDate, order: .reverse)
    private var tasks: [ProjectTask]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ActivitySummarySectionView(summary: viewModel.summary)

                    ActivityOverviewSectionView(
                        viewModel: viewModel,
                        isDashboardView: false,
                        cornerRadius: AppCornerRadius.prominent
                    )

                    ActivityDayDetailSectionView(
                        selectedDay: viewModel.selectedDay,
                        events: viewModel.selectedDayEvents
                    )
                }
                .padding()
                .readableContentWidth()
            }
            .navigationTitle("Activity")
            .onChange(of: reloadKey, initial: true) { _, _ in
                viewModel.reload(projects: projects, tasks: tasks)
            }
            .safeAreaInset(edge: .bottom) {
                CrossPromoBannerView()
            }
        }
    }

    private var reloadKey: Int {
        ActivityReloadKey.make(range: viewModel.selectedRange, projects: projects, tasks: tasks)
    }
}

#Preview("Light") {
    ActivityView()
        .modelContainer(SampleData.makePreviewContainer())
}

#Preview("Dark") {
    ActivityView()
        .modelContainer(SampleData.makePreviewContainer())
        .preferredColorScheme(.dark)
}
