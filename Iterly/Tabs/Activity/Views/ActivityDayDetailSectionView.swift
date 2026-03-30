//
//  ActivityDayDetailSectionView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI

struct ActivityDayDetailSectionView: View {
    let selectedDay: ActivityDaySummary?
    let events: [ActivityEvent]
    @State private var isExpanded: Bool = false

    private let collapsedLimit: Int = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Selected Day")
                .font(.headline)
                .padding(.vertical, 4)

            if let selectedDay {
                Text(selectedDay.date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                HStack(spacing: 0) {
                    Text("\(selectedDay.count) total")
                    Text("•")
                        .padding(.horizontal, 4)
                    Text("\(selectedDay.projectCount) project")
                    Text("•")
                        .padding(.horizontal, 4)
                    Text("\(selectedDay.taskCount) task")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

                Divider()
                    .padding(.bottom, 8)

                if events.isEmpty {
                    Text("No activity for this day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(visibleEvents) { event in
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Label(event.categoryTitle, systemImage: event.categorySystemImage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .labelStyle(.iconOnly)
                                .padding(.trailing, 8)

                            VStack(alignment: .leading) {
                                Text(event.title)
                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 4)
                    }

                    if hiddenEventCount > 0 {
                        Button(action: {
                            withAnimation(.snappy) {
                                isExpanded.toggle()
                            }
                        }) {
                            Text(isExpanded ? "Show less" : "Show more")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(/*.vertical, */8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Select a day to inspect activity.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 20))
        .onChange(of: selectedDay?.id) { _, _ in
            isExpanded = false
        }
    }

    private var visibleEvents: [ActivityEvent] {
        if isExpanded {
            return events
        }

        return Array(events.prefix(collapsedLimit))
    }

    private var hiddenEventCount: Int {
        max(events.count - collapsedLimit, 0)
    }
}

#Preview {
    ActivityDayDetailSectionView(
        selectedDay: ActivityDaySummary(
            date: .now,
            count: 5,
            projectCount: 2,
            taskCount: 3,
            intensityLevel: 3
        ),
        events: [
            ActivityEvent(
                date: .now,
                kind: .project,
                title: "Iterly",
                context: "In Progress",
                projectType: .app
            ),
            ActivityEvent(
                date: .now,
                kind: .task,
                title: "Ship activity heatmap",
                context: "Updated in Iterly",
                projectType: .app
            ),
            ActivityEvent(
                date: .now,
                kind: .task,
                title: "Polish summary card",
                context: "Updated in Iterly",
                projectType: .app
            )
        ]
    )
    .padding()
}
