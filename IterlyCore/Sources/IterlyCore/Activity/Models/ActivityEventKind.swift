//
//  ActivityEventKind.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

public enum ActivityEventKind: String, Hashable, Sendable {
    case project
    case task

    public var title: String {
        switch self {
        case .project: "Project"
        case .task: "Task"
        }
    }
}
