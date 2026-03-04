//
//  Priority-Enums.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation

enum ProjectPriority: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case low
    case normal
    case high

    var title: String {
        switch self {
        case .notSet:
            "Not Set"
        case .low:
            "Low"
        case .normal:
            "Normal"
        case .high:
            "High"
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case low
    case normal
    case high

    var title: String {
        switch self {
        case .notSet:
            "Not Set"
        case .low:
            "Low"
        case .normal:
            "Normal"
        case .high:
            "High"
        }
    }
}
