//
//  TasksSection.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct TasksSection: View {
    let tasks: [ProjectTask]?

    var body: some View {
        if let tasks, !tasks.isEmpty {
            VStack(alignment: .leading) {
                Text("Coming up tasks")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                ForEach(tasks) { task in
                    NavigationLink(value: task.id) {
                        TaskCell(title: task.title)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        TasksSection(tasks: SampleData.makeProjects().flatMap { $0.tasks ?? [] })
    }
}
