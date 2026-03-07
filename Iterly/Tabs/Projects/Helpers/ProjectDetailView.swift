//
//  ProjectDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/03/2026.
//

import SwiftData
import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project

    var body: some View {
        let tasks = project.tasks ?? []
        let activeTasks = tasks.filter { $0.status != .done }
        let completedTasks = tasks.filter { $0.status == .done }

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
                    LabeledContent("Current Release", value: releaseText(for: project))
                }
                .padding(.bottom)

                if !activeTasks.isEmpty {
                    Text("Tasks")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(activeTasks) { task in
                        TaskRowView(task: task)
                    }

                    Button(action: {
                        addTask()
                    }) {
                        Label("Add task", systemImage: "plus")
                    }
                    .padding(4)
                }

                if !completedTasks.isEmpty {
                    Text("Completed Tasks")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top)

                    ForEach(completedTasks) { task in
                        TaskRowView(task: task)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    project.isPinned.toggle()
                    project.touch()
                }) {
                    Image(systemName: "pin")
                        .rotationEffect(Angle(degrees: 45))
                        .symbolVariant(project.isPinned ? .fill : .none)
                }
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

    private func addTask() {
        withAnimation(.snappy) {
            let newTask = ProjectTask(project: project)
            modelContext.insert(newTask)

            if project.tasks == nil {
                project.tasks = []
            }
            project.tasks?.append(newTask)
            project.touch()
        }
    }
}

#Preview("Light") {
    NavigationStack {
        ProjectDetailView(project: SampleData.makeProjects()[0])
    }
    .modelContainer(SampleData.makePreviewContainer())
}
#Preview("Dark") {
    NavigationStack {
        ProjectDetailView(project: SampleData.makeProjects()[0])
            .preferredColorScheme(.dark)
    }
    .modelContainer(SampleData.makePreviewContainer())
}
