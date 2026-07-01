//
//  VideoThumbnailMaker.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import AVFoundation
import Foundation

/// Generates poster-frame thumbnails for video attachments. Call from a
/// background task so writing and decoding never block the main actor.
nonisolated enum VideoThumbnailMaker {
    /// Produces compact JPEG data for the video's first frame. The data is
    /// written to a temporary file because `AVURLAsset` requires a file URL.
    static func thumbnailData(
        fromVideoData videoData: Data,
        fileExtension: String,
        maxPixelSize: Int = 480
    ) async -> Data? {
        let temporaryURL = URL.temporaryDirectory
            .appending(path: "\(UUID().uuidString).\(fileExtension)")

        do {
            try videoData.write(to: temporaryURL)
        } catch {
            return nil
        }

        defer {
            try? FileManager.default.removeItem(at: temporaryURL)
        }

        let asset = AVURLAsset(url: temporaryURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: maxPixelSize, height: maxPixelSize)

        guard let posterFrame = try? await generator.image(at: .zero).image else {
            return nil
        }

        return ImageThumbnailMaker.jpegData(from: posterFrame)
    }
}
