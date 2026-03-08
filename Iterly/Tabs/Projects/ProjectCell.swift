//
//  ProjectCell.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

struct ProjectCell: View {
    let title: String
    let tasks: [ProjectTask]

    let blockedAmount: CGFloat
    let inProgressAmount: CGFloat
    let doneAmount: CGFloat

    let orderedStatuses: [TaskStatus] = [.blocked, .inProgress, .done, .notStarted]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(String.localizedStringWithFormat(NSLocalizedString("tasks_count", comment: "Tasks count"), tasks.count))
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: inProgressAmount + blockedAmount + doneAmount)
                .tint(tasks.first(where: { $0.status == .done })?.status.backgroundColor)
                .overlay {
                    ProgressView(value: inProgressAmount + blockedAmount)
                        .tint(tasks.first(where: { $0.status == .inProgress })?.status.backgroundColor)
                }
                .overlay {
                    ProgressView(value: blockedAmount)
                        .tint(tasks.first(where: { $0.status == .blocked })?.status.backgroundColor)
                }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
    }
}

#Preview {
    let data = SampleData.makeProjects()[0]
    ProjectCell(title: data.title, tasks: data.topLevelTasks, blockedAmount: 0.1, inProgressAmount: 0.2, doneAmount: 0.3)
}
