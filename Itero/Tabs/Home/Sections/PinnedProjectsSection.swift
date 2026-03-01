//
//  PinnedProjectsSection.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct PinnedProjectsSection: View {
    let projects: [Project]?

    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        if let projects, !projects.isEmpty {
            VStack(alignment: .leading) {
                pinnedHeaderView

                LazyVGrid(columns: columns) {
                    ForEach(projects) { project in
                        NavigationLink(value: HomeDestination.project(id: project.id)) {
                            ProjectCell(
                                title: project.title,
                                tasksCount: project.tasks?.count ?? 0
                            )
                            .background(Color.green.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    var pinnedHeaderView: some View {
        HStack {
            Image(systemName: "pin.fill")
                .imageScale(.small)
                .rotationEffect(Angle(degrees: 45))
            Text("Pinned")
                .font(.headline)
        }
        .padding(.horizontal)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        PinnedProjectsSection(projects: SampleData.makeProjects())
    }
}
