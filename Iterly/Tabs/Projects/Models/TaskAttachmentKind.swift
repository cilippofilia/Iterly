//
//  TaskAttachmentKind.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation

enum TaskAttachmentKind: String, CaseIterable, Codable {
    static let `default` = Self.image

    case image
    case video

    var title: String {
        switch self {
        case .image: "Image"
        case .video: "Video"
        }
    }
}
