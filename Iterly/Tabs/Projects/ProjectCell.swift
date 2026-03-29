//
//  ProjectCell.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

struct ProjectCell: View {
    let title: String
    let projectType: ProjectType
    let tasks: [ProjectTask]

    let blockedAmount: Double
    let inProgressAmount: Double
    let doneAmount: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Label(projectType.title, systemImage: projectType.systemImage)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
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
        .padding()
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
    }
}

#Preview {
    let data = SampleData.makeProjects()[0]
    ProjectCell(title: data.title, projectType: data.type, tasks: data.topLevelTasks, blockedAmount: 0.1, inProgressAmount: 0.2, doneAmount: 0.3)
}
