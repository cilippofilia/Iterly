//
//  Priority-Enums.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

public enum ProjectPriority: String, CaseIterable, Codable, Sendable {
    public static let `default` = Self.notSet

    case notSet
    case low
    case medium
    case high

    public var title: String {
        switch self {
        case .notSet: "Not Set"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .notSet: .gray
        case .low: .blue
        case .medium: .yellow
        case .high: .red
        }
    }
}

public enum TaskPriority: String, CaseIterable, Codable, Sendable {
    public static let `default` = Self.notSet

    case notSet
    case low
    case medium
    case high

    public var title: String {
        switch self {
        case .notSet: "Not Set"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
    public var badgeTitle: String {
        switch self {
        case .notSet: "P3"
        case .low: "P2"
        case .medium: "P1"
        case .high: "P0"
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .notSet: .gray
        case .low: .blue
        case .medium: .yellow
        case .high: .red
        }
    }

    public var sortRank: Int {
        switch self {
        case .high: 0
        case .medium: 1
        case .low: 2
        case .notSet: 3
        }
    }
}
