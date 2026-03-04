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

                if task.details.isEmpty == false {
                    Text(task.details)
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

                    LabeledContent("Priority", value: task.priority.title)

                    LabeledContent("Start Date") {
                        Text(task.startDate, format: .dateTime.month().day().year())
                    }

                    LabeledContent("Due Date") {
                        Text(task.dueDate, format: .dateTime.month().day().year())
                    }

                    LabeledContent("Created") {
                        Text(task.creationDate, format: .dateTime.month().day().year())
                    }

                    if let projectTitle = task.project?.title {
                        LabeledContent("Project", value: projectTitle)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: SampleData.makeProjects()[0].tasks?[0] ?? ProjectTask(title: "Test task"))
    }
}
