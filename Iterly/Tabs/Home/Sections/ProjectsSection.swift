//
//  ProjectsSection.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct ProjectsSection: View {
    @AppStorage("selectedView") private var selectedView: String?
    let projects: [Project]?
    let allProjectsCount: Int
    let showMore: Bool

    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let projects, !projects.isEmpty {
                HStack(spacing: .zero) {
                    Image(systemName: "folder")
                        .padding(.trailing, 4)
                    Text("Projects")
                        .padding(.trailing, 2)
                    Text("(\(allProjectsCount))")
                }
                .font(.headline)
                .padding(.horizontal)
                .foregroundStyle(.secondary)

                LazyVGrid(columns: columns) {
                    ForEach(projects) { project in
                        NavigationLink(value: project) {
                            ProjectCell(
                                title: project.title,
                                tasks: project.topLevelTasks,
                                blockedAmount: project.blockedAmount,
                                inProgressAmount: project.inProgressAmount,
                                doneAmount: project.doneAmount
                            )
                            .background(Color.secondary.gradient.opacity(0.2))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    if showMore {
                        SeeAllCellView(action: {
                            selectedView = ProjectsView.projectsTag
                        })
                        .background(Color.secondary.gradient.opacity(0.2))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectsSection(projects: SampleData.makeProjects(), allProjectsCount: 6, showMore: true)
    }
    .modelContainer(SampleData.makePreviewContainer())
}
