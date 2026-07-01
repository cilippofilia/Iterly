//
//  TaskAttachmentThumbnailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import SwiftUI

struct TaskAttachmentThumbnailView: View {
    let attachment: TaskAttachment

    private let side: CGFloat = 76

    @State private var image: CGImage?

    var body: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(.quaternary)

                Image(systemName: attachment.kind == .video ? "video" : "photo")
                    .foregroundStyle(.secondary)
            }

            if attachment.kind == .video, image != nil {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
        }
        .frame(width: side, height: side)
        .clipShape(.rect(cornerRadius: AppCornerRadius.small))
        .task(id: attachment.id) {
            guard image == nil else { return }
            guard let data = attachment.thumbnailData ?? attachment.data else { return }

            image = await Task.detached(priority: .userInitiated) {
                ImageThumbnailMaker.decodeImage(from: data, maxPixelSize: 480)
            }.value
        }
    }
}
