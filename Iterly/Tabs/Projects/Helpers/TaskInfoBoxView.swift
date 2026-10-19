//
//  TaskInfoBoxView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct TaskInfoBoxView: View {
    @Bindable var task: ProjectTask

    @Environment(\.modelContext) private var modelContext
    @Environment(CrossPromoSignal.self) private var crossPromoSignal

    var body: some View {
        let overdueDays = TaskOverdueCalculator.overdueDays(dueDate: task.dueDate)

        VStack(alignment: .leading, spacing: 8) {
            Text("Info")
                .bold()
                .padding(.horizontal)
                .padding(.top)

            LabeledContent("Status") {
                Menu {
                    Picker("Status", selection: Binding(
                        get: { task.status },
                        set: { newStatus in
                            if task.updateStatus(newStatus) {
                                crossPromoSignal.bump()
                            }
                            modelContext.saveLoggingFailure("task status")
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
                            task.updatePriority($0)
                            modelContext.saveLoggingFailure("task priority")
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
                            task.updateDueDate($0)
                            modelContext.saveLoggingFailure("task due date")
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(.horizontal)
            } else {
                LabeledContent("Due Date") {
                    Text(LocalizedText.noDueDate)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            if let overdueDays {
                Text(LocalizedText.overdueDays(overdueDays))
                    .font(.caption)
                    .foregroundStyle(.red)
                    .bold()
                    .padding(.horizontal)
            }
        }
        .padding(.bottom)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }
}
