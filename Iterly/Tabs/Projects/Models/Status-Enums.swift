//
//  Status-Enums.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation

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
}
