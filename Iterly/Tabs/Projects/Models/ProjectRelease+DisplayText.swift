//
//  ProjectRelease+DisplayText.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import Foundation

extension ProjectRelease {
    var displayText: String? {
        guard version.isEmpty == false else { return nil }
        return "v\(version)"
    }
}

extension Project {
    var releaseDisplayText: String? {
        currentRelease?.displayText
    }
}
