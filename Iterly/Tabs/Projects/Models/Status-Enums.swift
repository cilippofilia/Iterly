//
//  Status-Enums.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import Foundation
import SwiftUI

enum ProjectStatus: String, CaseIterable, Codable {
    static let `default` = Self.plan

    case plan
    case dev
    case beta
    case live
    case blocked
    case closed

    var title: String {
        switch self {
        case .plan: "Planning"
        case .dev: "Development"
        case .beta: "Beta"
        case .live: "Live"
        case .blocked: "Blocked"
        case .closed: "Closed"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .plan: .blue
        case .dev: .orange
        case .beta: .purple
        case .live: .green
        case .blocked: .red
        case .closed: .gray
        }
    }
}

enum TaskStatus: String, CaseIterable, Codable {
    static let `default` = Self.notStarted

    case blocked
    case notStarted
    case inProgress
    case done
    case closed

    var title: String {
        switch self {
        case .blocked: "Blocked"
        case .notStarted: "Not Started"
        case .inProgress: "In Progress"
        case .done: "Done"
        case .closed: "Closed"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .blocked: .red
        case .notStarted: .gray
        case .inProgress: .blue
        case .done: .green
        case .closed: .gray
        }
    }
}
