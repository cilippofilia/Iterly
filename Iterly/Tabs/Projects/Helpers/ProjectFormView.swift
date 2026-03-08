//
//  ProjectFormView.swift
//  Iterly
//
//  Created by Filippo Cilia on 07/03/2026.
//

import SwiftData
import SwiftUI

struct ProjectFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = ProjectViewModel()
    @State private var title = ""
    @State private var details = ""
    @State private var note = ""
    @State private var version = ""
    @State private var build = ""
    @State private var priority: ProjectPriority = .default
    @State private var status: ProjectStatus = .default
    @State private var isPinned = false
    @State private var isEditing = true

    private let project: Project?

    init(project: Project? = nil) {
        self.project = project
        _isEditing = State(initialValue: project != nil)
        _title = State(initialValue: project?.title ?? "")
        _details = State(initialValue: project?.details ?? "")
        _note = State(initialValue: project?.note ?? "")
        _version = State(initialValue: project?.currentRelease?.version ?? "")
        _build = State(initialValue: project?.currentRelease?.build ?? "")
        _priority = State(initialValue: project?.priority ?? .default)
        _status = State(initialValue: project?.status ?? .default)
        _isPinned = State(initialValue: project?.isPinned ?? false)
    }

    private var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Project Title", text: $title)
                TextField("Project Details", text: $details, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Info") {
                Picker("Status", selection: $status) {
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        Text(status.title)
                            .tag(status)
                    }
                }

                Picker("Priority", selection: $priority) {
                    ForEach(ProjectPriority.allCases, id: \.self) { priority in
                        Text(priority.title)
                            .tag(priority)
                    }
                }
            }

            Section("Release info") {
                TextField("Version", text: $version)
                TextField("Build number", text: $build)
            }

            Section("Brainstorm") {
                TextField("Note thoughts or features ideas here...", text: $note, axis: .vertical)
                    .lineLimit(3...6)
            }

            if isEditing {
                Section {
                    Button(action: {
                        closeProject()
                    }) {
                        Text("Close Project")
                    }

                    Button(role: .destructive, action: {
                        deleteProject()
                    }) {
                        Label("Delete Project", systemImage: "trash")
                    }
                    .foregroundStyle(.red)
                } footer: {
                    Text("Closing a project will hide it from the list; deleting it will also delete all tasks associated with it.")
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("New Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveProject()
                }
                .disabled(!canSave)
            }
        }
    }

    private func saveProject() {
        if let project {
            updateProject(project)
            dismiss()
            return
        }

        viewModel.createProject(
            title: title,
            details: details,
            note: note,
            priority: priority,
            status: status,
            isPinned: isPinned,
            version: version,
            build: build,
            modelContext: modelContext
        )
        dismiss()
    }

    private func updateProject(_ project: Project) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        project.title = trimmedTitle
        project.details = trimmedDetails.isEmpty ? nil : trimmedDetails
        project.note = trimmedNote.isEmpty ? nil : trimmedNote
        project.priority = priority
        project.status = status
        project.isPinned = isPinned
        project.touch()

        if let release = project.currentRelease {
            release.version = version
            release.build = build
        } else {
            let release = ProjectRelease(version: version, build: build, project: project)
            project.currentRelease = release
            modelContext.insert(release)
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to update project: \(error)")
        }
    }

    private func closeProject() {
        guard let project else { return }
        status = .closed
        isPinned = false
        updateProject(project)
        dismiss()
    }

    private func deleteProject() {
        guard let project else { return }
        viewModel.deleteProject(project, modelContext: modelContext)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ProjectFormView()
    }
    .modelContainer(SampleData.makePreviewContainer())
}
