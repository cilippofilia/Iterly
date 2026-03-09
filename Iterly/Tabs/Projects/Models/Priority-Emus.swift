//
//  Priority-Enums.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

enum ProjectPriority: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .notSet: "Not Set"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .notSet: .gray
        case .low: .blue
        case .medium: .yellow
        case .high: .red
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    static let `default` = Self.notSet

    case notSet
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .notSet: "Not Set"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
    var badgeTitle: String {
        switch self {
        case .notSet: "P3"
        case .low: "P2"
        case .medium: "P1"
        case .high: "P0"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .notSet: .gray
        case .low: .blue
        case .medium: .yellow
        case .high: .red
        }
    }

    var sortRank: Int {
        switch self {
        case .high: 0
        case .medium: 1
        case .low: 2
        case .notSet: 3
        }
    }
}
