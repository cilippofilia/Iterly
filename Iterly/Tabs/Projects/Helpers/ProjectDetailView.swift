//
//  ProjectDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/03/2026.
//

import SwiftData
import SwiftUI
import IterlyCore

struct ProjectDetailView: View {
    @Bindable var project: Project
    var onDelete: () -> Void = {}

    var body: some View {
        // The model may be deleted or erased while this screen is still on display.
        if project.isDeleted || project.modelContext == nil {
            ContentUnavailableView("Project Unavailable", systemImage: "folder.badge.questionmark")
        } else {
            ProjectDetailContentView(project: project, onDelete: onDelete)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        ProjectDetailView(project: SampleData.makeProjects()[0])
    }
    .modelContainer(SampleData.makePreviewContainer())
}
