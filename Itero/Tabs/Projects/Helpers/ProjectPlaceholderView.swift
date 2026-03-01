//
//  ProjectPlaceholderView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct ProjectPlaceholderView: View {
    let projectID: UUID

    var body: some View {
        Text("Project \(index)")
            .navigationTitle("Project")
    }
}

#Preview {
    NavigationStack {
        ProjectPlaceholderView(projectID: UUID())
    }
}
