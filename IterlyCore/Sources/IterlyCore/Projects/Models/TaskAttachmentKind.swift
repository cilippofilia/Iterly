//
//  TaskAttachmentKind.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation

public enum TaskAttachmentKind: String, CaseIterable, Codable, Sendable {
    public static let `default` = Self.image

    case image
    case video

    public var title: String {
        switch self {
        case .image: "Image"
        case .video: "Video"
        }
    }
}
