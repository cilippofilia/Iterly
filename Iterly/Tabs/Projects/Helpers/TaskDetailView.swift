//
//  TaskDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct TaskDetailView: View {
    let task: ProjectTask

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.title)
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)

            if let details = task.details, !details.isEmpty {
                Text(details)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle("Task")
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: SampleData.makeProjects()[0].tasks?[0] ?? ProjectTask(title: "Test task"))
    }
}
