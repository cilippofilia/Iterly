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
    @State private var showOversizedVideoAlert = false

    /// Keeps oversized videos out of the SwiftData store; external storage
    /// avoids bloating the database file, but device space still matters.
    private let maximumVideoByteCount = 200 * 1_000_000

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
        .fullScreenCover(item: $attachmentToView) { attachment in
            TaskAttachmentViewerView(attachment: attachment) {
                delete(attachment)
            }
        }
        .alert("Video Too Large", isPresented: $showOversizedVideoAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Videos larger than 200 MB can't be attached. Skipped: \(oversizedVideoCount).")
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

        var skippedVideos = 0

        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }

            let videoType = item.supportedContentTypes.first { $0.conforms(to: .movie) }

            let attachment: TaskAttachment
            if let videoType {
                guard data.count <= maximumVideoByteCount else {
                    skippedVideos += 1
                    continue
                }

                let fileExtension = videoType.preferredFilenameExtension ?? "mov"
                let thumbnailData = await Task.detached(priority: .userInitiated) {
                    await VideoThumbnailMaker.thumbnailData(
                        fromVideoData: data,
                        fileExtension: fileExtension
                    )
                }.value

                attachment = TaskAttachment(
                    kind: .video,
                    data: data,
                    thumbnailData: thumbnailData,
                    fileExtension: fileExtension,
                    task: task
                )
            } else {
                let thumbnailData = await Task.detached(priority: .userInitiated) {
                    ImageThumbnailMaker.thumbnailData(from: data)
                }.value

                attachment = TaskAttachment(
                    kind: .image,
                    data: data,
                    thumbnailData: thumbnailData,
                    task: task
                )
            }

            modelContext.insert(attachment)

            if task.attachments == nil {
                task.attachments = []
            }
            task.attachments?.append(attachment)
        }

        selectedItems = []
        task.touch()
        task.project?.touch()

        if skippedVideos > 0 {
            oversizedVideoCount = skippedVideos
            showOversizedVideoAlert = true
        }

        do {
            try modelContext.saveAndReloadActivityWidget()
        } catch {
            assertionFailure("Failed to save attachments: \(error)")
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
            assertionFailure("Failed to delete attachment: \(error)")
        }
    }
}
