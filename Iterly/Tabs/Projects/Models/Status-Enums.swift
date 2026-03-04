//
//  Status-Enums.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftUI

enum ProjectStatus: String, CaseIterable, Codable {
    static let `default` = Self.notStarted

    case notStarted
    case inProgress
    case done

    var title: String {
        switch self {
        case .notStarted:
            "Not Started"
        case .inProgress:
            "In Progress"
        case .done:
            "Done"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .inProgress:
            return .yellow
        case .done:
            return .green
        case .notStarted:
            return .secondary
        }
    }
}

enum TaskStatus: String, CaseIterable, Codable {
    static let `default` = Self.notStarted

    case notStarted
    case inProgress
    case done

    var title: String {
        switch self {
        case .notStarted:
            "Not Started"
        case .inProgress:
            "In Progress"
        case .done:
            "Done"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .inProgress:
            return .yellow
        case .done:
            return .green
        case .notStarted:
            return .secondary
        }
    }
}
