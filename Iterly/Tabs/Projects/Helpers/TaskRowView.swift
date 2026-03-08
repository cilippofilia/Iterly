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

            NavigationLink(value: task.id) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .frame(width: 3)
                    .foregroundStyle(isDone ? .secondary.opacity(0.5) : task.priority.backgroundColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .foregroundStyle(isDone ? .secondary : .primary)
                        .strikethrough(isDone, color: .secondary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 0) {
                        Text(task.priority.badgeTitle)
                            .padding(.trailing, 4)
                            .bold()

                        Text("Due:")
                            .padding(.trailing, 2)
                        Text(
                            task.dueDate,
                            format: .dateTime.day().month().year()
                        )
                        .bold()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

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
        .padding(4)
    }

    private func toggleTaskCompletion() {
        withAnimation(.snappy) {
            if task.status == .done {
                task.status = .inProgress
            } else {
                task.status = .done
            }
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
