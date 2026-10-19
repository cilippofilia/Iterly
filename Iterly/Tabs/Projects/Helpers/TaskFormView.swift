//
//  TaskFormView.swift
//  Iterly
//
//  Created by Filippo Cilia on 07/03/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(CrossPromoSignal.self) private var crossPromoSignal

    let project: Project
    private let task: ProjectTask?
    private let parentTask: ProjectTask?
    private let onDelete: (() -> Void)?

    @State private var title: String
    @State private var details: String
    @State private var note: String
    @State private var status: TaskStatus
    @State private var priority: TaskPriority
    @State private var hasDueDate: Bool
    @State private var dueDateDraft: Date

    @State private var isEditing: Bool
    @State private var showCloseAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorMessage: String?

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
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _dueDateDraft = State(initialValue: task?.dueDate ?? TaskFormView.defaultDueDate)
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

                Toggle("Has Due Date", isOn: $hasDueDate)

                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDateDraft, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
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
        .formStyle(.grouped)
        .navigationTitle(isEditing ? "Edit Task" : "New Task")
        .inlineNavigationBarTitle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    saveTask()
                } label: {
                    Text("Save")
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderedProminent)
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
        .alert("Something Went Wrong", item: $errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: {
            Text($0)
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
            if updateTask(task) {
                dismiss()
            }
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
            dueDate: hasDueDate ? dueDateDraft : nil,
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
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            // Roll the new task back so a retry doesn't create a duplicate.
            project.tasks?.removeAll { $0.id == task.id }
            parentTask?.subtasks?.removeAll { $0.id == task.id }
            modelContext.delete(task)
            errorMessage = error.localizedDescription
            return
        }

        crossPromoSignal.bump()
        dismiss()
    }

    /// Applies the form values to `task` and saves.
    /// - Returns: `true` if the save succeeded; on failure `errorMessage` is set.
    private func updateTask(_ task: ProjectTask) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let statusChanged = task.updateStatus(status)

        task.title = trimmedTitle
        task.details = trimmedDetails.isEmpty ? nil : trimmedDetails
        task.note = trimmedNote.isEmpty ? nil : trimmedNote
        task.priority = priority
        task.dueDate = hasDueDate ? dueDateDraft : nil
        task.touch()
        project.touch()

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            errorMessage = error.localizedDescription
            return false
        }

        if statusChanged {
            crossPromoSignal.bump()
        }
        return true
    }

    private func closeTask() {
        guard let task else { return }
        status = .closed
        if updateTask(task) {
            dismiss()
        }
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
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            // Restore the task so the form isn't left editing a deleted model.
            modelContext.rollback()
            errorMessage = error.localizedDescription
            return
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
    .environment(CrossPromoSignal())
}
