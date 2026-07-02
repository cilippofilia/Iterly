//
//  PinnedProjectsSection.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
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
                        NavigationLink(value: project) {
                            ProjectCell(
                                title: project.title,
                                projectType: project.type,
                                tasks: project.topLevelTasks,
                                blockedAmount: project.blockedAmount,
                                inProgressAmount: project.inProgressAmount,
                                doneAmount: project.doneAmount
                            )
                            .background(Color.secondary.gradient.opacity(0.2))
                            .clipShape(.rect(cornerRadius: AppCornerRadius.compact))
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
    .modelContainer(SampleData.makePreviewContainer())
}
