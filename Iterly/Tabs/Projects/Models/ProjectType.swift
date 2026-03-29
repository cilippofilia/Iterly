//
//  ProjectType.swift
//  Iterly
//
//  Created by Filippo Cilia on 29/03/2026.
//

import Foundation

enum ProjectType: String, CaseIterable, Codable {
    static let `default` = Self.app

    case app
    case package
    case website
    case agentSkill
    case automation
    case library
    case other

    var title: String {
        switch self {
        case .app: "App"
        case .package: "Package"
        case .website: "Website"
        case .agentSkill: "Agent Skill"
        case .automation: "Automation"
        case .library: "Library"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .app: "app.grid"
        case .package: "shippingbox"
        case .website: "globe"
        case .agentSkill: "brain"
        case .automation: "bolt"
        case .library: "books.vertical"
        case .other: "square.grid.2x2"
        }
    }
}
