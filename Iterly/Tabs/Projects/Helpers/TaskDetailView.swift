//
//  TaskDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskToEdit: ProjectTask?
    @State private var showAddSubtaskSheet: Bool = false
    @State private var showBrainstormSheet: Bool = false

    @Bindable var task: ProjectTask

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)

                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }

                TaskInfoBoxView(task: task)

                TaskActionsView(project: task.project, showBrainstormSheet: $showBrainstormSheet)

                TaskSubtaskSectionsView(
                    task: task,
                    onAddSubtask: {
                        showAddSubtaskSheet = true
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(task.project.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil.line") {
                    taskToEdit = task
                }
            }
        }
        .sheet(item: $taskToEdit) { task in
            NavigationStack {
                TaskFormView(project: task.project, task: task) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddSubtaskSheet) {
            if task.parentTask == nil {
                NavigationStack {
                    TaskFormView(project: task.project, parentTask: task)
                }
            }
        }
        .sheet(isPresented: $showBrainstormSheet) {
            NavigationStack {
                BrainstormFormView(text: Binding(
                    get: { task.note ?? "" },
                    set: {
                        task.note = $0.isEmpty ? nil : $0
                        task.touch()
                        task.project.touch()
                    }
                ))
            }
            .presentationDetents([.medium])
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
