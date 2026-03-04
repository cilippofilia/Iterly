//
//  ProjectDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/03/2026.
//

import SwiftUI

struct ProjectDetailView: View {
    @State private var isEditing: Bool = false

    let project: Project

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let title = project.title {
                    Text(title)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.primary)
                }
                if let details = project.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }

                GroupBox("Info") {
                    LabeledContent("Status", value: project.status?.title ?? "Unknown")
                    LabeledContent("Priority", value: project.priority?.title ?? "Normal")

                    if let startDate = project.startDate {
                        LabeledContent("Start Date") {
                            Text(startDate, format: .dateTime.month().day().year())
                        }
                    }

                    if let dueDate = project.dueDate {
                        LabeledContent("Due Date") {
                            Text(dueDate, format: .dateTime.month().day().year())
                        }
                    }
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
                                    .background(badgeColor(for: task).opacity(0.5))
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "square.and.pencil") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditProjectDetails(project: project)
        }
        .navigationDestination(for: UUID.self) { taskId in
            if let task = project.tasks?.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
    }

    private func badgeColor(for task: ProjectTask) -> Color {
        switch task.status {
        case .inProgress:
            return .yellow
        default:
            return .secondary
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
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: SampleData.makeProjects()[0])
    }
}
