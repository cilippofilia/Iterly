//
//  TaskListView.swift
//  Iterly
//
//  Created by Filippo Cilia on 29/03/2026.
//

import SwiftData
import SwiftUI

struct TaskListView: View {
    let title: String
    let tasks: [ProjectTask]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: UUID.self) { taskId in
            if let task = tasks.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskListView(
            title: "Completed Tasks",
            tasks: SampleData.makeProjects()[0].topLevelTasks
        )
    }
    .modelContainer(SampleData.makePreviewContainer())
}
