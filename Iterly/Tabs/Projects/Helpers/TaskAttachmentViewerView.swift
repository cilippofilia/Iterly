//
//  TaskAttachmentViewerView.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import AVKit
import SwiftUI
import IterlyCore

struct TaskAttachmentViewerView: View {
    @Environment(\.dismiss) private var dismiss

    let attachment: TaskAttachment
    let onDelete: () -> Void

    @State private var image: CGImage?
    @State private var player: AVPlayer?
    @State private var videoURL: URL?
    @State private var zoom: CGFloat = 1
    @State private var steadyZoom: CGFloat = 1
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                switch attachment.kind {
                case .image:
                    if let image {
                        Image(decorative: image, scale: 1)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(zoom)
                            .gesture(magnifyGesture)
                            .onTapGesture(count: 2) {
                                withAnimation(.snappy) {
                                    zoom = 1
                                    steadyZoom = 1
                                }
                            }
                            .accessibilityLabel("Attachment image")
                    } else {
                        ProgressView()
                    }

                case .video:
                    if let player {
                        VideoPlayer(player: player)
                            .accessibilityLabel("Attachment video")
                    } else {
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteAlert = true
                    }
                }
            }
            .alert("Delete Attachment?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    dismiss()
                    onDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove the attachment from the task.")
            }
            .task {
                await loadContent()
            }
            .onDisappear {
                player?.pause()
                if let videoURL {
                    try? FileManager.default.removeItem(at: videoURL)
                }
            }
        }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                zoom = min(max(steadyZoom * value.magnification, 1), 6)
            }
            .onEnded { _ in
                steadyZoom = zoom
            }
    }

    private func loadContent() async {
        guard let data = attachment.data else { return }

        switch attachment.kind {
        case .image:
            image = await Task.detached(priority: .userInitiated) {
                ImageThumbnailMaker.decodeImage(from: data, maxPixelSize: 2400)
            }.value

        case .video:
            // AVPlayer needs a file URL, so stage the stored data in a
            // temporary file that is removed when the viewer closes.
            let url = URL.temporaryDirectory
                .appending(path: "\(attachment.id.uuidString).\(attachment.fileExtension ?? "mov")")

            let didWrite = await Task.detached(priority: .userInitiated) {
                do {
                    try data.write(to: url)
                    return true
                } catch {
                    return false
                }
            }.value

            guard didWrite else { return }
            videoURL = url
            player = AVPlayer(url: url)
        }
    }
}
