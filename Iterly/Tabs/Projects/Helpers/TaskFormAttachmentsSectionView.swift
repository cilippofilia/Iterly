//
//  TaskFormAttachmentsSectionView.swift
//  Iterly
//

import PhotosUI
import SwiftUI
import IterlyCore

/// Collects media for a task that hasn't been saved yet; the form attaches them on save.
struct TaskFormAttachmentsSectionView: View {
    @Binding var attachments: [TaskAttachment]

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var errorMessage: String?

    var body: some View {
        Section("Attachments") {
            if attachments.isEmpty == false {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(attachments) { attachment in
                            TaskAttachmentThumbnailView(attachment: attachment)
                                .accessibilityLabel(attachment.kind == .video ? "Video" : "Photo")
                                .contextMenu {
                                    Button("Remove", systemImage: "trash", role: .destructive) {
                                        attachments.removeAll { $0.id == attachment.id }
                                    }
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            if isImporting {
                ProgressView()
            } else {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .any(of: [.images, .videos])
                ) {
                    Label("Add Media", systemImage: "photo.badge.plus")
                }
            }
        }
        .onChange(of: selectedItems) { _, items in
            guard items.isEmpty == false else { return }
            Task {
                await importMedia(items)
            }
        }
        .alert("Something Went Wrong", item: $errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: {
            Text($0)
        }
    }

    private func importMedia(_ items: [PhotosPickerItem]) async {
        isImporting = true
        defer { isImporting = false }

        let result = await TaskMediaImporter.makeAttachments(from: items)
        attachments.append(contentsOf: result.attachments)
        selectedItems = []

        let messages = [
            result.oversizedVideoCount > 0
                ? "Videos larger than 200 MB can't be attached. Skipped: \(result.oversizedVideoCount)." : nil,
            result.failedItemCount > 0
                ? "^[\(result.failedItemCount) item](inflect: true) couldn't be imported." : nil
        ].compactMap(\.self)

        if messages.isEmpty == false {
            errorMessage = messages.joined(separator: "\n")
        }
    }
}
