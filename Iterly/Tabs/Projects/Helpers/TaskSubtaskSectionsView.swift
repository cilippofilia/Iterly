//
//  TaskSubtaskSectionsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct TaskSubtaskSectionsView: View {
    let task: ProjectTask
    let onAddSubtask: () -> Void

    var body: some View {
        if task.parentTask == nil {
            let sections = TaskSectionsBuilder.sections(for: task.subtasks ?? [])

            if !sections.active.isEmpty {
                TaskListSectionView(
                    title: "Subtasks",
                    tasks: sections.active,
                    shouldNavigate: false
                )
                TertiaryCapsuleActionButton(
                    title: "Add subtask",
                    systemImage: "plus",
                    action: onAddSubtask
                )
                .padding(4)
            } else {
                ContentUnavailableView(
                    label: { Text("There are no active subtasks") },
                    description: { Text("This task has no subtasks yet. Press the button below to get started.") },
                    actions: {
                        PrimaryCapsuleActionButton(
                            title: "Add subtask",
                            systemImage: "plus",
                            action: onAddSubtask
                        )
                    }
                )
                .padding(8)
            }

            if !sections.completed.isEmpty {
                TaskListSectionView(
                    title: "Completed Subtasks",
                    tasks: sections.completed,
                    shouldNavigate: false
                )
            }

            if !sections.closed.isEmpty {
                TaskListSectionView(
                    title: "Closed Subtasks",
                    tasks: sections.closed,
                    shouldNavigate: false
                )
            }
        }
    }
}
