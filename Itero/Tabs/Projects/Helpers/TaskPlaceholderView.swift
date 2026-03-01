//
//  TaskPlaceholderView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct TaskPlaceholderView: View {
    let title: String

    var body: some View {
        Text("Task \(title)")
            .navigationTitle("Task")
    }
}

#Preview {
    NavigationStack {
        TaskPlaceholderView(title: "Test task")
    }
}
