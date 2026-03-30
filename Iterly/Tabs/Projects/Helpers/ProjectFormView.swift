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
    @State private var appStoreURL = ""
    @State private var type: ProjectType = .default
    @State private var priority: ProjectPriority = .default
    @State private var status: ProjectStatus = .default
    @State private var isPinned = false
    @State private var isEditing = true
    @State private var isSaving = false
    @State private var syncErrorMessage: String?

    private let project: Project?

    init(project: Project? = nil) {
        self.project = project
        _isEditing = State(initialValue: project != nil)
        _title = State(initialValue: project?.title ?? "")
        _details = State(initialValue: project?.details ?? "")
        _note = State(initialValue: project?.note ?? "")
        _version = State(initialValue: project?.currentRelease?.version ?? "")
        _appStoreURL = State(initialValue: project?.currentRelease?.appStoreURL ?? "")
        _type = State(initialValue: project?.type ?? .default)
        _priority = State(initialValue: project?.priority ?? .default)
        _status = State(initialValue: project?.status ?? .default)
        _isPinned = State(initialValue: project?.isPinned ?? false)
    }

    private var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && isSaving == false
    }

    private var isAppStoreLinked: Bool {
        project?.currentRelease?.hasAppStoreLink == true
    }

    private var willSyncFromAppStoreURL: Bool {
        appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Project Title", text: $title)
                TextField("Project Details", text: $details, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Info") {
                Picker("Type", selection: $type) {
                    ForEach(ProjectType.allCases, id: \.self) { type in
                        Label(type.title, systemImage: type.systemImage)
                            .tag(type)
                    }
                }

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
                if isAppStoreLinked {
                    LabeledContent("Version") {
                        Text(version.isEmpty ? "Unavailable" : version)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    TextField("Version", text: $version)
                }

                if isAppStoreLinked {
                    LabeledContent("App Store URL") {
                        Text(appStoreURL.isEmpty ? "Unavailable" : appStoreURL)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                } else {
                    TextField("App Store URL", text: $appStoreURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if let syncDateText = project?.currentRelease?.appStoreSyncDateText, isAppStoreLinked {
                    LabeledContent("Last Sync") {
                        Text(syncDateText)
                            .foregroundStyle(.secondary)
                    }
                }

                if let syncErrorMessage {
                    Text(syncErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                } else if let storedError = project?.currentRelease?.appStoreSyncError, storedError.isEmpty == false {
                    Text(storedError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let project, isAppStoreLinked {
                    Button("Refresh from App Store") {
                        Task {
                            await refreshLinkedRelease(for: project)
                        }
                    }
                    .disabled(isSaving)

                    Button("Disconnect App Store Link", role: .destructive) {
                        disconnectLinkedRelease(for: project)
                    }
                    .disabled(isSaving)
                } else if willSyncFromAppStoreURL {
                    Text("The version will be fetched from the App Store when you save this project.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
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
                    Task {
                        await saveProject()
                    }
                }
                .disabled(!canSave)
            }
        }
        .alert("App Store Sync Failed", isPresented: Binding(
            get: { syncErrorMessage != nil },
            set: { newValue in
                if newValue == false {
                    syncErrorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                syncErrorMessage = nil
            }
        } message: {
            Text(syncErrorMessage ?? "Something went wrong.")
        }
    }

    private func saveProject() async {
        isSaving = true
        defer { isSaving = false }

        do {
            if let project {
                try await viewModel.updateProject(
                    project,
                    title: title,
                    details: details,
                    note: note,
                    type: type,
                    priority: priority,
                    status: status,
                    isPinned: isPinned,
                    version: version,
                    appStoreURL: appStoreURL,
                    modelContext: modelContext
                )
            } else {
                try await viewModel.createProject(
                    title: title,
                    details: details,
                    note: note,
                    type: type,
                    priority: priority,
                    status: status,
                    isPinned: isPinned,
                    version: version,
                    appStoreURL: appStoreURL,
                    modelContext: modelContext
                )
            }

            dismiss()
        } catch {
            syncErrorMessage = error.localizedDescription
        }
    }

    private func closeProject() {
        guard let project else { return }
        status = .closed
        isPinned = false
        Task {
            await saveProject()
        }
    }

    private func deleteProject() {
        guard let project else { return }
        viewModel.deleteProject(project, modelContext: modelContext)
        dismiss()
    }

    private func refreshLinkedRelease(for project: Project) async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await viewModel.refreshAppStoreRelease(for: project, modelContext: modelContext)
            version = project.currentRelease?.version ?? version
            appStoreURL = project.currentRelease?.appStoreURL ?? appStoreURL
            syncErrorMessage = nil
        } catch {
            viewModel.saveAppStoreSyncError(error, for: project, modelContext: modelContext)
            syncErrorMessage = error.localizedDescription
        }
    }

    private func disconnectLinkedRelease(for project: Project) {
        do {
            try viewModel.disconnectAppStoreRelease(for: project, modelContext: modelContext)
            syncErrorMessage = nil
        } catch {
            syncErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ProjectFormView()
    }
    .modelContainer(SampleData.makePreviewContainer())
}
