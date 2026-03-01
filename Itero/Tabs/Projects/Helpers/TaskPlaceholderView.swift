//
//  TaskPlaceholderView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct TaskPlaceholderView: View {
    let taskID: UUID

    var body: some View {
        Text("Task \(0)")
            .navigationTitle("Task")
    }
}

#Preview {
    NavigationStack {
        TaskPlaceholderView(taskID: UUID())
    }
}
