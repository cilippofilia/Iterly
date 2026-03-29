//
//  TaskListSectionView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct TaskListSectionView: View {
    let title: String
    let tasks: [ProjectTask]
    let shouldNavigate: Bool
    private let previewLimit: Int = 5

    private var displayedTasks: [ProjectTask] {
        if shouldNavigate {
            Array(tasks.prefix(previewLimit))
        } else {
            tasks
        }
    }

    private var showsNavigationLink: Bool {
        shouldNavigate && tasks.count > previewLimit
    }

    var body: some View {
        if showsNavigationLink {
            NavigationLink {
                TaskListView(title: title, tasks: tasks)
            } label: {
                HStack {
                    HStack(spacing: 4) {
                        Text(title)
                        Text("(\(tasks.count))")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                }
                .font(.headline)
                .padding(.top)
                .contentShape(.rect)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        } else {
            HStack {
                HStack(spacing: 4) {
                    Text(title)
                    Text("(\(tasks.count))")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.headline)
            .padding(.top)
            .foregroundStyle(.secondary)
        }

        ForEach(displayedTasks) { task in
            TaskRowView(task: task)
        }
    }
}
