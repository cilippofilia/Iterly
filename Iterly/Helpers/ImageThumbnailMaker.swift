//
//  ImageThumbnailMaker.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Downsamples and decodes image data via ImageIO. Call from a background
/// task so large photo library imports never block the main actor.
nonisolated enum ImageThumbnailMaker {
    /// Produces compact JPEG data for grid previews, capped at `maxPixelSize`
    /// on the longest edge.
    static func thumbnailData(from imageData: Data, maxPixelSize: Int = 480) -> Data? {
        guard let thumbnail = decodeImage(from: imageData, maxPixelSize: maxPixelSize) else {
            return nil
        }

        return jpegData(from: thumbnail)
    }

    /// Encodes a `CGImage` as compressed JPEG data.
    static func jpegData(from image: CGImage) -> Data? {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        let destinationOptions = [
            kCGImageDestinationLossyCompressionQuality: 0.8
        ] as CFDictionary
        CGImageDestinationAddImage(destination, image, destinationOptions)

        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }

    /// Decodes image data into a `CGImage`, downsampled to `maxPixelSize` on
    /// the longest edge and rotated upright.
    static func decodeImage(from imageData: Data, maxPixelSize: Int) -> CGImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(imageData as CFData, sourceOptions) else {
            return nil
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary

        return CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions)
    }
}
