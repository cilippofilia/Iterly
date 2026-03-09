//
//  UnavailableProjectsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 05/03/2026.
//

import SwiftUI

struct UnavailableProjectsView: View {
    @State private var showAddProjectSheet = false

    var body: some View {
        ContentUnavailableView {
            Label("No projects found", systemImage: "folder.badge.questionmark")
        } description: {
            Text("There are no active projects at the moment. Create one to get started.")
        } actions: {
            createProjectButton
        }
        .sheet(isPresented: $showAddProjectSheet) {
            NavigationStack {
                ProjectFormView()
            }
        }
    }

    private var createProjectButton: some View {
        Button(
            "Add Project",
            systemImage: "plus",
            action: {
                showAddProjectSheet = true
            }
        )
    }
}

#Preview {
    UnavailableProjectsView()
}
