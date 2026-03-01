//
//  ProjectPriority.swift
//  Itero
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
}
