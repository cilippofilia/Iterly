//
//  TasksSection.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct TasksSection: View {
    let title: String
    let tasks: [ProjectTask]?

    var body: some View {
        let upcomingTasks = tasks ?? []

        if !upcomingTasks.isEmpty {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                ForEach(upcomingTasks) { task in
                    TaskRowView(task: task)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            TasksSection(title: "Upcoming task", tasks: SampleData.makeProjects().flatMap { $0.topLevelTasks })
        }
    }
    .modelContainer(SampleData.makePreviewContainer())
}
