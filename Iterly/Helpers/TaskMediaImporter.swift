//
//  TaskMediaImporter.swift
//  Iterly
//

import PhotosUI
import SwiftUI
import IterlyCore

/// Turns photo library picks into `TaskAttachment` models, ready to be inserted and linked to a task.
enum TaskMediaImporter {
    struct Result {
        var attachments: [TaskAttachment] = []
        var oversizedVideoCount = 0
        var failedItemCount = 0
    }

    /// Keeps oversized videos out of the SwiftData store; external storage
    /// avoids bloating the database file, but device space still matters.
    static let maximumVideoByteCount = 200 * 1_000_000

    /// Loads each item and builds an attachment with a thumbnail.
    /// The attachments are not inserted into any context and have no task yet.
    static func makeAttachments(from items: [PhotosPickerItem]) async -> Result {
        var result = Result()

        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                result.failedItemCount += 1
                continue
            }

            let videoType = item.supportedContentTypes.first { $0.conforms(to: .movie) }

            if let videoType {
                guard data.count <= maximumVideoByteCount else {
                    result.oversizedVideoCount += 1
                    continue
                }

                let fileExtension = videoType.preferredFilenameExtension ?? "mov"
                let thumbnailData = await Task.detached(priority: .userInitiated) {
                    await VideoThumbnailMaker.thumbnailData(
                        fromVideoData: data,
                        fileExtension: fileExtension
                    )
                }.value

                result.attachments.append(TaskAttachment(
                    kind: .video,
                    data: data,
                    thumbnailData: thumbnailData,
                    fileExtension: fileExtension
                ))
            } else {
                let thumbnailData = await Task.detached(priority: .userInitiated) {
                    ImageThumbnailMaker.thumbnailData(from: data)
                }.value

                result.attachments.append(TaskAttachment(
                    kind: .image,
                    data: data,
                    thumbnailData: thumbnailData
                ))
            }
        }

        return result
    }
}
