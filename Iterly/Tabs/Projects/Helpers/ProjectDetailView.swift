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
    @State private var viewModel = ProjectViewModel()
    @State private var showPinLimitAlert: Bool = false
    @State private var projectToEdit: Project?
    @State private var showAddTaskSheet: Bool = false
    @Bindable var project: Project

    var body: some View {
        let tasks = project.topLevelTasks
        let activeTasks = tasks.filter { $0.status != .done && $0.status != .closed }
        let completedTasks = tasks.filter { $0.status == .done }
        let closedTasks = tasks.filter { $0.status == .closed }

        ScrollView {
            VStack(alignment: .leading) {
                projectDescriptionView

                infoBoxSection

                if !activeTasks.isEmpty {
                    tasksSection(label: "Tasks", for: activeTasks)
                    addTaskButton
                        .padding(4)
                } else {
                    noTasksAvailableView
                }
                if !completedTasks.isEmpty {
                    tasksSection(label: "Completed Tasks", for: completedTasks)
                }
                if !closedTasks.isEmpty {
                    tasksSection(label: "Closed Tasks", for: closedTasks)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(project.title)
        .contentMargins(.bottom, 70, for: .scrollContent)
        .navigationDestination(for: UUID.self) { taskId in
            if let task = project.tasks?.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    project.isPinned.toggle()
                }) {
                    Image(systemName: "pin")
                        .rotationEffect(Angle(degrees: 45))
                        .symbolVariant(project.isPinned ? .fill : .none)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil.line") {
                    projectToEdit = project
                }
            }
        }
        .sheet(item: $projectToEdit) { project in
            NavigationStack {
                ProjectFormView(project: project)
            }
        }
        .sheet(isPresented: $showAddTaskSheet) {
            NavigationStack {
                TaskFormView(project: project)
            }
        }
        .alert("Can't Pin Project", isPresented: $showPinLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Only 4 projects can be pinned at the same time.")
        }
    }

    private func releaseText(for project: Project) -> String? {
        guard let release = project.currentRelease else { return nil }
        if release.version.isEmpty, release.build.isEmpty { return nil }
        if release.version.isEmpty {
            return "Build \(release.build)"
        }
        if release.build.isEmpty {
            return "v\(release.version)"
        }
        return "v\(release.version) (\(release.build))"
    }
}

private extension ProjectDetailView {
    @ViewBuilder
    var projectDescriptionView: some View {
        if let details = project.details, !details.isEmpty {
            Text(details)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }

    var infoBoxSection: some View {
        VStack(alignment: .leading) {
            Text("Info")
                .bold()
                .padding([.horizontal, .top])

            statusLabel
            priorityLabel
            currentReleaseLabel
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }

    var statusLabel: some View {
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
    }

    var priorityLabel: some View {
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
        .padding(.bottom, releaseText(for: project) != nil ? 0 : 16)
    }

    @ViewBuilder
    var currentReleaseLabel: some View {
        if let releaseText = releaseText(for: project) {
            HStack {
                Text("Current Release")
                Spacer()
                Text(releaseText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding([.horizontal, .bottom])
        }
    }

    @ViewBuilder
    func tasksSection(
        label: String,
        for tasks: [ProjectTask]
    ) -> some View {
        Text(label)
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.top)
        ForEach(tasks) { task in
            TaskRowView(task: task)
        }
    }

    var addTaskButton: some View {
        Button(action: {
            showAddTaskSheet = true
        }) {
            Label("Add task", systemImage: "plus")
        }
        .buttonStyle(.borderedProminent)
    }

    var noTasksAvailableView: some View {
        ContentUnavailableView(
            label: { Text("There are no active tasks") },
            description: { Text("This project has no tasks yet. Press the button below to get started.") },
            actions: {
                addTaskButton
            }
        )
        .padding(8)
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
