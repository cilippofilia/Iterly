//
//  TaskRowView.swift
//  Iterly
//
//  Created by Filippo Cilia on 05/03/2026.
//

import SwiftData
import SwiftUI

struct TaskRowView: View {
    let task: ProjectTask

    var body: some View {
        let isDone = task.status == .done
        let isClosed = task.status == .closed
        let isActive = isDone == false && isClosed == false
        let overdueDays = TaskOverdueCalculator.overdueDays(dueDate: task.dueDate)
        let isOverdue = isActive && overdueDays != nil
        let subtaskCount = task.subtasks?.count ?? 0
        let subtaskLabel = LocalizedText.subtasksCount(subtaskCount)

        HStack(alignment: .firstTextBaseline) {
            Button(
                "Toggle Status",
                systemImage: isDone ? "checkmark.circle" : "circle"
            ) {
                toggleTaskCompletion()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(isDone ? .green : .secondary)
            .symbolEffect(.bounce, value: isDone)
            .buttonStyle(.plain)

            NavigationLink {
                TaskDetailView(task: task)
            } label: {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .frame(width: 3)
                    .foregroundStyle(isDone ? .secondary.opacity(0.5) : task.priority.backgroundColor)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.title)
                            .foregroundStyle(isDone ? .secondary : .primary)
                            .strikethrough(isDone, color: .secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Menu {
                            Picker("Status", selection: Binding(
                                get: { task.status },
                                set: {
                                    task.status = $0
                                    task.touch()
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

                    if subtaskCount > 0 {
                        Text(subtaskLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 0) {
                        Text(task.priority.badgeTitle)
                            .padding(.trailing, 4)
                            .bold()

                        Text("Due:")
                            .padding(.trailing, 2)
                        if let dueDate = task.dueDate {
                            Text(
                                dueDate,
                                format: .dateTime.day().month().year()
                            )
                            .bold()
                            .strikethrough(isOverdue, color: .secondary)
                            .padding(.trailing, 4)

                            if let overdueDays, isOverdue {
                                Text(LocalizedText.overdueDays(overdueDays))
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .bold()
                            }
                        } else {
                            Text(LocalizedText.noDueDate)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
    }

    private func toggleTaskCompletion() {
        withAnimation(.snappy) {
            if task.status == .done {
                task.status = .inProgress
            } else {
                task.status = .done
            }
            task.touch()
            task.project.touch()
        }
    }
}

#Preview {
    TaskRowView(
        task: SampleData.makeProjects()[0].tasks?[0] ?? .init(project: SampleData.makeProjects()[0])
    )
    .frame(height: 55)
    .modelContainer(SampleData.makePreviewContainer())
}
