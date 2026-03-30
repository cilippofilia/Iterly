//
//  ActivitySummarySectionView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI

struct ActivitySummarySectionView: View {
    let summary: ActivityOverviewSummary
    @State private var showDefinitionsAlert: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                metric(
                    title: "Streak",
                    value: "\(summary.streak)",
                    metricIcon: "flame",
                    iconColor: .red,
                    detail: summary.streak == 1 ? "active day" : "active days"
                )
                .frame(maxWidth: .infinity, alignment: .center)
                metric(
                    title: "Total",
                    value: "\(summary.totalCount)",
                    metricIcon: "cellularbars",
                    iconColor: .blue,
                    detail: "activities"
                )
                .frame(maxWidth: .infinity, alignment: .center)
                metric(
                    title: "Busiest",
                    value: busiestValue,
                    metricIcon: "fireworks",
                    iconColor: .indigo,
                    detail: busiestDetail
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .overlay(alignment: .topTrailing) {
            Button("Info", systemImage: "info.circle") {
                showDefinitionsAlert = true
            }
            .imageScale(.small)
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding()
        }
        .background(.thinMaterial, in: .rect(cornerRadius: 20))
        .alert("Activity Summary", isPresented: $showDefinitionsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(definitionsMessage)
        }
    }

    private var busiestValue: String {
        guard let busiestDay = summary.busiestDay else { return "None" }
        return "\(busiestDay.count)"
    }

    private var busiestDetail: String {
        guard let busiestDay = summary.busiestDay else { return "no activity" }

        return busiestDay.date.formatted(.dateTime.month(.abbreviated).day())
    }

    private var definitionsMessage: String {
        """
        Streak is the number of consecutive days with at least one activity event recorded.

        Total is the overall number of activity events recorded.

        Busiest is the day with the highest number of activity events recorded.
        """
    }

    private func metric(
        title: String,
        value: String,
        metricIcon: String,
        iconColor: Color,
        detail: String
    ) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Image(systemName: metricIcon)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(iconColor.gradient, .orange)
                Text(value)
                    .font(.title2)
                    .bold()
                    .monospacedDigit()
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ActivitySummarySectionView(
        summary: ActivityOverviewSummary(
            totalCount: 56,
            streak: 5,
            busiestDay: ActivityDaySummary(
                date: .now,
                count: 12,
                projectCount: 4,
                taskCount: 8,
                intensityLevel: 4
            )
        )
    )
    .padding()
}
