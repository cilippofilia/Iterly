//
//  ActivityOverviewSectionView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI
import SwiftData

@MainActor
struct ActivityOverviewSectionView: View {
    @Bindable var viewModel: ActivityOverviewViewModel

    let cornerRadius: CGFloat
    var isHeatmapInteractive: Bool = true
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Activity Overview")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let trailingAction {
                    Button(action: trailingAction) {
                        Label("Open", systemImage: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

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
                },
                isInteractive: isHeatmapInteractive
            )

            ActivityLegendView()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: cornerRadius))
    }
}

#Preview("Interactive") {
    @Previewable @State var viewModel = ActivityOverviewViewModel()
    let projects = SampleData.makeProjects()

    ActivityOverviewSectionView(
        viewModel: viewModel,
        cornerRadius: AppCornerRadius.prominent
    )
    .padding()
    .task {
        viewModel.reload(projects: projects, tasks: projects.flatMap { $0.tasks ?? [] })
    }
    .modelContainer(SampleData.makePreviewContainer())
}

#Preview("Home Style") {
    @Previewable @State var viewModel = ActivityOverviewViewModel()
    let projects = SampleData.makeProjects()

    ActivityOverviewSectionView(
        viewModel: viewModel,
        cornerRadius: AppCornerRadius.regular,
        isHeatmapInteractive: false,
        trailingAction: {}
    )
    .padding()
    .task {
        viewModel.reload(projects: projects, tasks: projects.flatMap { $0.tasks ?? [] })
    }
    .modelContainer(SampleData.makePreviewContainer())
}
