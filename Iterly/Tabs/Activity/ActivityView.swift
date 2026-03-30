//
//  ActivityView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftData
import SwiftUI

@MainActor
struct ActivityView: View {
    static let activityTag: String? = "Activity"

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

                    VStack(alignment: .leading) {
                        Text("Activity Overview")
                            .font(.headline)

                        Picker("Range", selection: $viewModel.selectedRange) {
                            ForEach(ActivityRange.allCases) { range in
                                Text(range.title)
                                    .tag(range)
                            }
                        }
                        .pickerStyle(.segmented)

                        ActivityHeatmapGridView(
                            weeks: viewModel.weeks,
                            monthLabels: viewModel.monthLabels,
                            selectedDay: viewModel.selectedDay,
                            onSelectDay: { day in
                                viewModel.selectDay(day)
                            }
                        )

                        ActivityLegendView()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(.thinMaterial, in: .rect(cornerRadius: AppCornerRadius.prominent))

                    ActivityDayDetailSectionView(
                        selectedDay: viewModel.selectedDay,
                        events: viewModel.selectedDayEvents
                    )
                }
                .padding()
                .padding(.bottom, 24)
            }
            .navigationTitle("Activity")
            .onChange(of: reloadToken, initial: true) { _, _ in
                viewModel.reload(projects: projects, tasks: tasks)
            }
        }
    }

    private var reloadToken: String {
        let projectToken = projects
            .map { project in
                "\(project.id.uuidString)-\(project.lastUpdated.timeIntervalSinceReferenceDate)"
            }
            .joined(separator: ",")
        let taskToken = tasks
            .map { task in
                "\(task.id.uuidString)-\(task.creationDate.timeIntervalSinceReferenceDate)-\(task.lastUpdated?.timeIntervalSinceReferenceDate ?? 0)"
            }
            .joined(separator: ",")

        return [
            viewModel.selectedRange.rawValue,
            projectToken,
            taskToken
        ].joined(separator: "|")
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
