//
//  TaskDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct TaskDetailView: View {
    @Bindable var task: ProjectTask

    var body: some View {
        if let project = task.project {
            TaskDetailContentView(task: task, project: project)
        } else {
            ContentUnavailableView(
                "Task Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text("This task is no longer linked to a project.")
            )
        }
    }
}

#Preview {
    let project = SampleData.makeProjects()[0]
    let task = project.tasks?.first ?? ProjectTask(
        title: "Test title",
        details: "Test details",
        status: .default,
        dueDate: .now.addingTimeInterval(14 * 24 * 60 * 60),
        priority: .default,
        creationDate: .now,
        project: project
    )

    NavigationStack {
        TaskDetailView(task: task)
    }
    .modelContainer(SampleData.makePreviewContainer())
}
