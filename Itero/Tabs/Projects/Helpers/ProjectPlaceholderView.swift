//
//  ProjectPlaceholderView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct ProjectPlaceholderView: View {
    let title: String

    var body: some View {
        Text("Project \(title)")
            .navigationTitle("Project")
    }
}

#Preview {
    NavigationStack {
        ProjectPlaceholderView(title: "Test project")
    }
}
