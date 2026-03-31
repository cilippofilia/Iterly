//
//  ProjectInfoBoxView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct ProjectInfoBoxView: View {
    @Bindable var project: Project

    var body: some View {
        VStack(alignment: .leading) {
            Text("Info")
                .bold()
                .padding([.horizontal, .top])

            LabeledContent("Type") {
                Label(project.type.title, systemImage: project.type.systemImage)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            LabeledContent("Status") {
                Menu {
                    Picker("Status", selection: Binding(
                        get: { project.status },
                        set: {
                            project.status = $0
                            project.touch()
                        }
                    )) {
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            Text(status.title)
                                .tag(status)
                        }
                    }
                } label: {
                    Text(project.status.title)
                        .badgeStyle(backgroundColor: project.status.backgroundColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            LabeledContent("Priority") {
                Menu {
                    Picker("Priority", selection: Binding(
                        get: { project.priority },
                        set: {
                            project.priority = $0
                            project.touch()
                        }
                    )) {
                        ForEach(ProjectPriority.allCases, id: \.self) { priority in
                            Text(priority.title)
                                .tag(priority)
                        }
                    }
                } label: {
                    Text(project.priority.title)
                        .badgeStyle(backgroundColor: project.priority.backgroundColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            if let releaseText = project.releaseDisplayText {
                HStack {
                    Text("Current Release")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(releaseText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: AppCornerRadius.compact, style: .continuous))
    }
}

#Preview {
    ProjectInfoBoxView(project: SampleData.makeProjects()[0])
}
