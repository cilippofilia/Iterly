//
//  TaskDetailContentView.swift
//  Iterly
//

import SwiftData
import SwiftUI
import IterlyCore

struct TaskDetailContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskToEdit: ProjectTask?
    @State private var showAddSubtaskSheet: Bool = false
    @State private var showBrainstormSheet: Bool = false

    @Bindable var task: ProjectTask
    let project: Project

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

                TaskActionsView(project: project, showBrainstormSheet: $showBrainstormSheet)

                TaskAttachmentsSectionView(task: task)

                TaskSubtaskSectionsView(
                    task: task,
                    onAddSubtask: {
                        showAddSubtaskSheet = true
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
            .readableContentWidth()
        }
        .navigationTitle(project.title)
        .toolbar {
            ToolbarItem(placement: .platformTopBarTrailing) {
                Button("Edit", systemImage: "pencil.line") {
                    taskToEdit = task
                }
            }
        }
        .sheet(item: $taskToEdit) { task in
            NavigationStack {
                TaskFormView(project: project, task: task) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddSubtaskSheet) {
            NavigationStack {
                TaskFormView(project: project, parentTask: task)
            }
        }
        .sheet(isPresented: $showBrainstormSheet) {
            NavigationStack {
                BrainstormFormView(text: Binding(
                    get: { task.note ?? "" },
                    set: {
                        task.note = $0.isEmpty ? nil : $0
                        task.touch()
                        project.touch()
                    }
                ))
            }
            .presentationDetents([.medium])
        }
    }
}
