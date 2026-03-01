//
//  TasksSection.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct TasksSection: View {
    let tasks: [ProjectTask]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Up next:")
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach(tasks.enumerated(), id: \.element.id) { index, task in
                NavigationLink(value: HomeDestination.task(id: task.id)) {
                    TaskCell(title: task.title)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        TasksSection(tasks: SampleData.makeProjects().flatMap { $0.tasks ?? [] })
    }
}
