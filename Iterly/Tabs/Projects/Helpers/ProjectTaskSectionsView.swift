//
//  ProjectTaskSectionsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct ProjectTaskSectionsView: View {
    let sections: TaskSectionsBuilder.Sections
    let onAddTask: () -> Void

    var body: some View {
        if !sections.active.isEmpty {
            TaskListSectionView(
                title: "Tasks",
                tasks: sections.active,
                shouldNavigate: false
            )
            TertiaryCapsuleActionButton(
                title: "Add task",
                systemImage: "plus",
                action: onAddTask
            )
            .padding(4)
        } else {
            ContentUnavailableView(
                label: { Text("There are no active tasks") },
                description: { Text("This project has no tasks yet. Press the button below to get started.") },
                actions: {
                    PrimaryCapsuleActionButton(
                        title: "Add task",
                        systemImage: "plus",
                        action: onAddTask
                    )
                }
            )
            .padding(8)
        }

        if !sections.completed.isEmpty {
            TaskListSectionView(
                title: "Completed Tasks",
                tasks: sections.completed,
                shouldNavigate: true
            )
        }

        if !sections.closed.isEmpty {
            TaskListSectionView(
                title: "Closed Tasks",
                tasks: sections.closed,
                shouldNavigate: true
            )
        }
    }
}
