//
//  TaskListView.swift
//  Iterly
//
//  Created by Filippo Cilia on 29/03/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct TaskListView: View {
    let title: String
    let tasks: [ProjectTask]
    var isToned: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                        .opacity(isToned ? 0.6 : 1)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TaskListView(
            title: "Completed Tasks",
            tasks: SampleData.makeProjects()[0].topLevelTasks
        )
    }
    .modelContainer(SampleData.makePreviewContainer())
}
