//
//  TaskDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct TaskDetailView: View {
    let task: ProjectTask

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)

                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }

                GroupBox("Info") {
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
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(task.project.title)
        .scrollBounceBehavior(.basedOnSize)
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
