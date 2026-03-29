//
//  ProjectRowView.swift
//  Iterly
//
//  Created by Filippo Cilia on 06/03/2026.
//

import SwiftUI

struct ProjectRowView: View {
    let title: String
    let projectType: ProjectType
    let statusTitle: String
    let statusColor: Color
    let currentRelease: ProjectRelease?
    let tasks: [ProjectTask]

    let blockedAmount: Double
    let inProgressAmount: Double
    let doneAmount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Label(projectType.title, systemImage: projectType.systemImage)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)

                Text(title)
                    .bold()
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(statusTitle)
                    .badgeStyle(backgroundColor: statusColor)
            }

            if let releaseText = currentRelease?.displayText {
                Text(releaseText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(LocalizedText.tasksCount(tasks.count))
                .font(.caption)
                .foregroundStyle(.secondary)

            TaskProgressView(
                tasks: tasks,
                blockedAmount: blockedAmount,
                inProgressAmount: inProgressAmount,
                doneAmount: doneAmount
            )
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let data = SampleData.makeProjects()[0]
    ProjectRowView(
        title: data.title,
        projectType: data.type,
        statusTitle: data.status.title,
        statusColor: data.status.backgroundColor,
        currentRelease: data.currentRelease,
        tasks: data.topLevelTasks,
        blockedAmount: 0.1,
        inProgressAmount: 0.3,
        doneAmount: 0.4
    )
}
