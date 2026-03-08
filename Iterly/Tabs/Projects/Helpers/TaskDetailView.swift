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

    let task: ProjectTask

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                headerSection
                infoBoxSection
                goToProjectButton
                if task.parentTask == nil {
                    subtasksSection
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(task.project.title)
        .navigationDestination(for: UUID.self) { taskId in
            if let task = task.project.tasks?.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
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
            if canHaveSubtasks {
                NavigationStack {
                    TaskFormView(project: task.project, parentTask: task)
                }
            }
        }
    }

    private var overdueDays: Int? {
        let calendar = Calendar.autoupdatingCurrent
        let dueDay = calendar.startOfDay(for: task.dueDate)
        let today = calendar.startOfDay(for: .now)
        guard dueDay < today else { return nil }
        let days = calendar.dateComponents([.day], from: dueDay, to: today).day ?? 0
        return max(days, 1)
    }
}

private extension TaskDetailView {
    @ViewBuilder
    var headerSection: some View {
        Text(task.title)
            .font(.title2)
            .bold()
            .foregroundStyle(.primary)

        if let details = task.details, !details.isEmpty {
            Text(details)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }

    private var infoBoxSection: some View {
        VStack(alignment: .leading) {
            Text("Info")
                .bold()
                .padding([.horizontal, .top])

            statusLabel
            priorityLabel
            datePickerSection
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }

    private var statusLabel: some View {
        LabeledContent("Status") {
            Menu {
                Picker("Status", selection: Binding(
                    get: { task.status },
                    set: {
                        task.status = $0
                        task.project.touch()
                    }
                )) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Text(status.title)
                            .tag(status)
                    }
                }
            } label: {
                Text(task.status.title)
                    .badgeStyle(backgroundColor: task.status.backgroundColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    var priorityLabel: some View {
        LabeledContent("Priority") {
            Menu {
                Picker("Priority", selection: Binding(
                    get: { task.priority },
                    set: {
                        task.priority = $0
                        task.project.touch()
                    }
                )) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.title)
                            .tag(priority)
                    }
                }
            } label: {
                Text(task.priority.title)
                    .badgeStyle(backgroundColor: task.priority.backgroundColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    var datePickerSection: some View {
        DatePicker(
            "Due Date",
            selection: Binding(
                get: { task.dueDate },
                set: {
                    task.dueDate = $0
                    task.project.touch()
                }
            ),
            displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .padding(.horizontal)
        .padding(.vertical, 8)

        if let overdueDays {
            Text(
                String.localizedStringWithFormat(
                    NSLocalizedString("overdue_days", comment: "Overdue days label"),
                    overdueDays
                )
            )
            .foregroundStyle(.red)
            .bold()
            .padding([.horizontal, .bottom])
        }
    }

    var goToProjectButton: some View {
        NavigationLink(value: task.project) {
            Label("Go to Project", systemImage: "folder")
        }
        .buttonStyle(.borderedProminent)
    }

    var addSubtaskButton: some View {
        Button(action: {
            showAddSubtaskSheet = true
        }) {
            Label("Add subtask", systemImage: "plus")
        }
        .buttonStyle(.borderedProminent)
    }

    @ViewBuilder
    var subtasksSection: some View {
        if canHaveSubtasks {
            let subtasks = task.subtasks ?? []
            let activeSubtasks = subtasks.filter { $0.status != .done && $0.status != .closed }
            let completedSubtasks = subtasks.filter { $0.status == .done }
            let closedSubtasks = subtasks.filter { $0.status == .closed }

            VStack(alignment: .leading) {
                if !activeSubtasks.isEmpty {
                    tasksSection(label: "Subtasks", for: activeSubtasks)
                    addSubtaskButton
                        .padding(4)
                } else {
                    noSubtasksAvailableView
                }
                if !completedSubtasks.isEmpty {
                    tasksSection(label: "Completed Subtasks", for: completedSubtasks)
                }
                if !closedSubtasks.isEmpty {
                    tasksSection(label: "Closed Subtasks", for: closedSubtasks)
                }
            }
        }
    }

    @ViewBuilder
    func tasksSection(
        label: String,
        for tasks: [ProjectTask]
    ) -> some View {
        Text(label)
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.top)
        ForEach(tasks) { task in
            TaskRowView(task: task)
        }
    }

    var noSubtasksAvailableView: some View {
        ContentUnavailableView(
            label: { Text("There are no active subtasks") },
            description: { Text("This task has no subtasks yet. Press the button below to get started.") },
            actions: {
                addSubtaskButton
            }
        )
        .padding(8)
    }

    var canHaveSubtasks: Bool {
        task.parentTask == nil
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
