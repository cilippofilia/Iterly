//
//  ProjectDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/03/2026.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(project.title)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)

                if let details = project.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }

                GroupBox("Info") {
                    LabeledContent("Status") {
                        Menu {
                            Picker("Status", selection: Binding(
                                get: { project.status },
                                set: { project.status = $0 }
                            )) {
                                ForEach(ProjectStatus.allCases, id: \.self) { status in
                                    Text(status.title)
                                        .tag(status)
                                }
                            }
                        } label: {
                            Text(project.status.title)
                        }
                        .buttonStyle(.plain)
                    }
                    LabeledContent("Priority") {
                        Menu {
                            Picker("Priority", selection: Binding(
                                get: { project.priority },
                                set: { project.priority = $0 }
                            )) {
                                ForEach(ProjectPriority.allCases, id: \.self) { priority in
                                    Text(priority.title)
                                        .tag(priority)
                                }
                            }
                        } label: {
                            Text(project.priority.title)
                        }
                        .buttonStyle(.plain)
                    }
                    LabeledContent("Current Release", value: releaseText(for: project))
                }
                .padding(.bottom)

                if let tasks = project.tasks, !tasks.isEmpty {
                    Text("Tasks")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(tasks) { task in
                        HStack {
                            Button(
                                "Toggle Status",
                                systemImage: isTaskDone(for: task) ? "checkmark.circle" : "circle"
                            ) {
                                toggleTaskCompletion(for: task)
                            }
                            .labelStyle(.iconOnly)
                            .foregroundStyle(isTaskDone(for: task) ? .green : .secondary)
                            .symbolEffect(.bounce, value: isTaskDone(for: task))
                            .buttonStyle(.plain)

                            NavigationLink(value: task.id) {
                                Text(task.title)
                                    .foregroundStyle(isTaskDone(for: task) ? .secondary : .primary)
                                    .strikethrough(isTaskDone(for: task), color: .secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .buttonStyle(.plain)

                            Spacer(minLength: 8)

                            Menu {
                                Picker("Status", selection: Binding(
                                    get: { task.status },
                                    set: { task.status = $0 }
                                )) {
                                    ForEach(TaskStatus.allCases, id: \.self) { status in
                                        Text(status.title)
                                            .tag(status)
                                    }
                                }
                            } label: {
                                Text(task.status.title.uppercased())
                                    .font(.caption2)
                                    .bold()
                                    .contentTransition(.numericText())
                                    .padding(4)
                                    .background(task.status.backgroundColor.opacity(0.5))
                                    .clipShape(.rect(cornerRadius: 4, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(4)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationDestination(for: UUID.self) { taskId in
            if let task = project.tasks?.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
    }

    private func isTaskDone(for task: ProjectTask) -> Bool {
        return task.status == .done
    }

    private func toggleTaskCompletion(for task: ProjectTask) {
        withAnimation(.snappy) {
            if task.status == .done {
                task.status = .inProgress
            } else {
                task.status = .done
            }
        }
    }

    private func releaseText(for project: Project) -> String {
        guard let release = project.currentRelease else {
            return "Not Set"
        }

        if release.version.isEmpty, release.build.isEmpty {
            return "Not Set"
        }

        if release.version.isEmpty {
            return "Build \(release.build)"
        }

        if release.build.isEmpty {
            return "v\(release.version)"
        }

        return "v\(release.version) (\(release.build))"
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: SampleData.makeProjects()[0])
    }
}
