//
//  TaskInfoBoxView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct TaskInfoBoxView: View {
    @Bindable var task: ProjectTask

    var body: some View {
        let overdueDays = TaskOverdueCalculator.overdueDays(dueDate: task.dueDate)
        let bottomRowPadding: CGFloat = overdueDays == nil ? 16 : 8

        VStack(alignment: .leading) {
            Text("Info")
                .bold()
                .padding([.horizontal, .top])

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

            if task.dueDate != nil {
                DatePicker(
                    "Due Date",
                    selection: Binding(
                        get: { task.dueDate ?? .now },
                        set: {
                            task.dueDate = $0
                            task.project.touch()
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, bottomRowPadding)
            } else {
                LabeledContent("Due Date") {
                    Text(LocalizedText.noDueDate)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, bottomRowPadding)
            }

            if let overdueDays {
                Text(LocalizedText.overdueDays(overdueDays))
                    .foregroundStyle(.red)
                    .bold()
                    .padding([.horizontal, .bottom])
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }
}
