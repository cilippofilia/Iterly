//
//  ProjectsSection.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftUI

struct ProjectsSection: View {
    let projects: [Project]
    private let rows = [GridItem(.fixed(100))]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                // add limit of 5 then 6th will be a `see more` that opens projects tabs
                ForEach(projects.enumerated(), id: \.element.id) { index, project in
                    NavigationLink(value: HomeDestination.project(id: project.id)) {
                        ProjectCell(title: project.title, tasksCount: project.tasks?.count ?? 0)
                            .background(Color.yellow.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack {
        ProjectsSection(projects: SampleData.makeProjects())
    }
}
