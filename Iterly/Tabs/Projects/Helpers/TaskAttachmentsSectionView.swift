//
//  TaskAttachmentsSectionView.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import PhotosUI
import SwiftData
import SwiftUI
import IterlyCore

struct TaskAttachmentsSectionView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var task: ProjectTask

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var attachmentToView: TaskAttachment?
    @State private var isImporting = false
    @State private var oversizedVideoCount = 0
    @State private var failedImportCount = 0
    @State private var showOversizedVideoAlert = false
    @State private var errorMessage: String?

    private var attachments: [TaskAttachment] {
        (task.attachments ?? []).sorted { $0.creationDate < $1.creationDate }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if attachments.isEmpty {
                ContentUnavailableView(
                    label: { Text("There are no attachments") },
                    description: { Text("Add screenshots, photos, or videos to reference bugs and ideas visually.") },
                    actions: {
                        if isImporting {
                            ProgressView()
                        } else {
                            addMediaPicker {
                                Label("Add media", systemImage: "photo.badge.plus")
                                    .primaryCapsuleButtonStyle()
                            }
                        }
                    }
                )
                .padding(8)
            } else {
                HStack {
                    HStack(spacing: 4) {
                        Text("Attachments")
                        Text("(\(attachments.count))")
                    }
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if isImporting {
                        ProgressView()
                    } else {
                        addMediaPicker {
                            Label("Add media", systemImage: "photo.badge.plus")
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.top)

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(attachments) { attachment in
                            Button {
                                attachmentToView = attachment
                            } label: {
                                TaskAttachmentThumbnailView(attachment: attachment)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("View attachment")
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    delete(attachment)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onChange(of: selectedItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                await importMedia(items)
            }
        }
        .platformFullScreenCover(item: $attachmentToView) { attachment in
            TaskAttachmentViewerView(attachment: attachment) {
                delete(attachment)
            }
            .macSheetMinimumSize()
        }
        .alert("Video Too Large", isPresented: $showOversizedVideoAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if failedImportCount > 0 {
                Text("Videos larger than 200 MB can't be attached. Skipped: \(oversizedVideoCount).\n^[\(failedImportCount) item](inflect: true) couldn't be imported.")
            } else {
                Text("Videos larger than 200 MB can't be attached. Skipped: \(oversizedVideoCount).")
            }
        }
        .alert("Something Went Wrong", item: $errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: {
            Text($0)
        }
    }

    private func addMediaPicker(@ViewBuilder label: () -> some View) -> some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 10,
            matching: .any(of: [.images, .videos]),
            label: label
        )
    }

    private func importMedia(_ items: [PhotosPickerItem]) async {
        isImporting = true
        defer { isImporting = false }

        let result = await TaskMediaImporter.makeAttachments(from: items)
        let skippedVideos = result.oversizedVideoCount
        let failedItems = result.failedItemCount

        for attachment in result.attachments {
            attachment.task = task
            modelContext.insert(attachment)

            if task.attachments == nil {
                task.attachments = []
            }
            task.attachments?.append(attachment)
        }

        selectedItems = []
        task.touch()
        task.project?.touch()

        var saveErrorMessage: String?
        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            saveErrorMessage = error.localizedDescription
        }

        let failedMessage = failedItems > 0 ? "^[\(failedItems) item](inflect: true) couldn't be imported." : nil

        // Only one alert can be presented at a time: a save error takes priority,
        // then oversized videos (which also report failed items), then failed items alone.
        if let saveErrorMessage {
            errorMessage = [saveErrorMessage, failedMessage].compactMap(\.self).joined(separator: "\n")
        } else if skippedVideos > 0 {
            oversizedVideoCount = skippedVideos
            failedImportCount = failedItems
            showOversizedVideoAlert = true
        } else if let failedMessage {
            errorMessage = failedMessage
        }
    }

    private func delete(_ attachment: TaskAttachment) {
        if let index = task.attachments?.firstIndex(where: { $0.id == attachment.id }) {
            task.attachments?.remove(at: index)
        }
        modelContext.delete(attachment)
        task.touch()
        task.project?.touch()

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
