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

    @State private var viewModel: ProjectFormViewModel

    init(
        project: Project? = nil,
        presetStore: CustomLinkLabelPresetStore = CustomLinkLabelPresetStore()
    ) {
        _viewModel = State(
            initialValue: ProjectFormViewModel(
                project: project,
                presetStore: presetStore
            )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section("Details") {
                TextField("Project Title", text: $viewModel.title)
                TextField("Project Details", text: $viewModel.details, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Info") {
                Picker("Type", selection: $viewModel.type) {
                    ForEach(ProjectType.allCases, id: \.self) { type in
                        Label(type.title, systemImage: type.systemImage)
                            .tag(type)
                    }
                }

                Picker("Status", selection: $viewModel.status) {
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        Text(status.title)
                            .tag(status)
                    }
                }

                Picker("Priority", selection: $viewModel.priority) {
                    ForEach(ProjectPriority.allCases, id: \.self) { priority in
                        Text(priority.title)
                            .tag(priority)
                    }
                }
            }

            Section("Release info") {
                if viewModel.isAppStoreLinked {
                    LabeledContent("Version") {
                        Text(viewModel.version.isEmpty ? "Unavailable" : viewModel.version)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    TextField("Version", text: $viewModel.version)
                }

                if viewModel.isAppStoreLinked {
                    LabeledContent("App Store URL") {
                        Text(viewModel.appStoreURL.isEmpty ? "Unavailable" : viewModel.appStoreURL)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .minimumScaleFactor(0.75)
                    }
                } else {
                    TextField("App Store URL", text: $viewModel.appStoreURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if let syncDateText = viewModel.lastSyncText {
                    LabeledContent("Last Sync") {
                        Text(syncDateText)
                            .foregroundStyle(.secondary)
                    }
                }

                if viewModel.project != nil, viewModel.isAppStoreLinked {
                    Button("Refresh from App Store") {
                        Task {
                            await viewModel.refreshLinkedRelease(modelContext: modelContext)
                        }
                    }
                    .disabled(viewModel.isSaving)

                    Button("Disconnect App Store Link", role: .destructive) {
                        viewModel.disconnectLinkedRelease(modelContext: modelContext)
                    }
                    .disabled(viewModel.isSaving)
                } else if viewModel.willSyncFromAppStoreURL {
                    Text("The version will be fetched from the App Store when you save this project.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Notes") {
                TextField("Brainstorm, context, or next steps", text: $viewModel.note, axis: .vertical)
                    .lineLimit(4...8)
            }

            Section("Useful links") {
                ForEach($viewModel.usefulLinkDrafts) { $draft in
                    VStack(alignment: .leading) {
                        HStack {
                            if draft.kind == .custom {
                                Label(ProjectLinkKind.custom.title, systemImage: draft.kind.systemImage)
                                    .foregroundStyle(.secondary)
                                TextField("Custom label", text: $draft.customLabel)
                                    .textInputAutocapitalization(.words)
                            } else {
                                Menu {
                                    ForEach(ProjectLinkKind.allCases.filter { $0 != .custom }) { kind in
                                        Button(kind.title, systemImage: kind.systemImage) {
                                            draft.kind = kind
                                            if draft.customLabel.isEmpty == false {
                                                draft.customLabel = ""
                                            }
                                        }
                                    }

                                    if viewModel.customLinkLabelPresets.isEmpty == false {
                                        Section("Your Labels") {
                                            ForEach(viewModel.customLinkLabelPresets, id: \.self) { preset in
                                                Button(preset, systemImage: ProjectLinkKind.custom.systemImage) {
                                                    draft.kind = .custom
                                                    draft.customLabel = preset
                                                }
                                            }
                                        }
                                    }

                                    Button("Custom Label", systemImage: ProjectLinkKind.custom.systemImage) {
                                        draft.kind = .custom
                                        if draft.customLabel.isEmpty {
                                            draft.customLabel = ""
                                        }
                                    }
                                } label: {
                                    Label(draft.displayLabel, systemImage: draft.kind.systemImage)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Button(role: .destructive) {
                                viewModel.removeUsefulLinkDraft(draft.id)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }

                        HStack {
                            TextField("URL", text: $draft.url)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }
                }

                Button("Add New URL", systemImage: "plus") {
                    viewModel.addUsefulLinkDraft()
                }
            }

            if viewModel.isEditing {
                Section {
                    Button(action: {
                        Task {
                            if await viewModel.close(modelContext: modelContext) {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Close Project")
                    }

                    Button(role: .destructive, action: {
                        viewModel.deleteProject(modelContext: modelContext)
                        dismiss()
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
        .navigationTitle(viewModel.navigationTitle)
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
                        if await viewModel.save(modelContext: modelContext) {
                            dismiss()
                        }
                    }
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert("App Store Sync Failed", isPresented: Binding(
            get: { viewModel.syncErrorMessage != nil },
            set: { newValue in
                if newValue == false {
                    viewModel.clearSyncError()
                }
            }
        )) {
            Button("OK", role: .cancel) {
                viewModel.clearSyncError()
            }
        } message: {
            Text(viewModel.syncErrorMessage ?? "Something went wrong.")
        }
}

}

#Preview {
    NavigationStack {
        ProjectFormView()
    }
    .modelContainer(SampleData.makePreviewContainer())
}
