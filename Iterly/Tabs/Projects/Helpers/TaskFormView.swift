//
//  TaskFormView.swift
//  Iterly
//
//  Created by Filippo Cilia on 07/03/2026.
//

import SwiftData
import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let project: Project
    private let task: ProjectTask?
    private let parentTask: ProjectTask?
    private let onDelete: (() -> Void)?

    @State private var title = ""
    @State private var details = ""
    @State private var note = ""
    @State private var status: TaskStatus = .default
    @State private var priority: TaskPriority = .default
    @State private var dueDate: Date = TaskFormView.defaultDueDate

    @State private var isEditing: Bool = false
    @State private var showCloseAlert: Bool = false
    @State private var showDeleteAlert: Bool = false

    init(
        project: Project,
        task: ProjectTask? = nil,
        parentTask: ProjectTask? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.project = project
        self.task = task
        self.parentTask = parentTask ?? task?.parentTask
        self.onDelete = onDelete
        _isEditing = State(initialValue: task != nil)
        _title = State(initialValue: task?.title ?? "")
        _details = State(initialValue: task?.details ?? "")
        _note = State(initialValue: task?.note ?? "")
        _status = State(initialValue: task?.status ?? .default)
        _priority = State(initialValue: task?.priority ?? .default)
        _dueDate = State(initialValue: task?.dueDate ?? TaskFormView.defaultDueDate)
    }

    private var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Task Title", text: $title)
                TextField("Task Details", text: $details, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Settings") {
                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Text(status.title)
                            .tag(status)
                    }
                }

                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.title)
                            .tag(priority)
                    }
                }

                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            Section("Brainstorm") {
                TextField("Note thoughts or features ideas here...", text: $note, axis: .vertical)
                    .lineLimit(3...6)
            }

            if isEditing {
                Section {
                    Button(action: {
                        showCloseAlert = true
                    }) {
                        Text("Close Task")
                    }

                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Label("Delete Task", systemImage: "trash")
                    }
                    .foregroundStyle(.red)
                } footer: {
                    Text("Closing a task marks it as done; deleting it removes it from the project.")
                        .font(.footnote)
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Task" : "New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveTask()
                }
                .disabled(!canSave)
            }
        }
        .alert("Close Task?", isPresented: $showCloseAlert) {
            Button("Close Task", role: .destructive) {
                closeTask()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will mark the task as closed.")
        }
        .alert("Delete Task?", isPresented: $showDeleteAlert) {
            Button("Delete Task", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the task from the project.")
        }
    }

    private func saveTask() {
        if let task {
            updateTask(task)
            dismiss()
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        let task = ProjectTask(
            title: trimmedTitle,
            details: trimmedDetails.isEmpty ? nil : trimmedDetails,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            status: status,
            dueDate: dueDate,
            priority: priority,
            creationDate: .now,
            project: project,
            parentTask: parentTask
        )

        modelContext.insert(task)

        if project.tasks == nil {
            project.tasks = []
        }
        project.tasks?.append(task)

        if let parentTask {
            if parentTask.subtasks == nil {
                parentTask.subtasks = []
            }
            parentTask.subtasks?.append(task)
        }
        project.touch()

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to create task: \(error)")
        }

        dismiss()
    }

    private func updateTask(_ task: ProjectTask) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        task.title = trimmedTitle
        task.details = trimmedDetails.isEmpty ? nil : trimmedDetails
        task.note = trimmedNote.isEmpty ? nil : trimmedNote
        task.status = status
        task.priority = priority
        task.dueDate = dueDate
        task.project.touch()

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to update task: \(error)")
        }
    }

    private func closeTask() {
        guard let task else { return }
        status = .closed
        updateTask(task)
        dismiss()
    }

    private func deleteTask() {
        guard let task else { return }
        if let index = project.tasks?.firstIndex(where: { $0.id == task.id }) {
            project.tasks?.remove(at: index)
        }
        if let parentTask,
           let index = parentTask.subtasks?.firstIndex(where: { $0.id == task.id }) {
            parentTask.subtasks?.remove(at: index)
        }
        modelContext.delete(task)
        project.touch()

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete task: \(error)")
        }

        dismiss()
        onDelete?()
    }

    private static var defaultDueDate: Date {
        Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
    }
}

#Preview {
    NavigationStack {
        TaskFormView(project: SampleData.makeProjects()[0])
    }
    .modelContainer(SampleData.makePreviewContainer())
}
