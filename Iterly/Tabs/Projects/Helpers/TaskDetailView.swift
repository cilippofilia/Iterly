//
//  TaskDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

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
                                set: { task.status = $0 }
                            )) {
                                ForEach(TaskStatus.allCases, id: \.self) { status in
                                    Text(status.title)
                                        .tag(status)
                                }
                            }
                        } label: {
                            Text(task.status.title)
                        }
                        .buttonStyle(.plain)
                    }

                    LabeledContent("Priority") {
                        Menu {
                            Picker("Priority", selection: Binding(
                                get: { task.priority },
                                set: { task.priority = $0 }
                            )) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Text(priority.title)
                                        .tag(priority)
                                }
                            }
                        } label: {
                            Text(task.priority.title)
                        }
                        .buttonStyle(.plain)
                    }
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
        dueDate: .distantFuture,
        priority: .default,
        creationDate: .now,
        project: project
    )

    NavigationStack {
        TaskDetailView(task: task)
    }
}
