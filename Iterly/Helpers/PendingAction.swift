//
//  PendingAction.swift
//  Iterly
//
//  Created by Filippo Cilia on 3/31/26.
//

import SwiftUI

enum PendingAction: Identifiable {
    case appStore(Project)
    case usefulLink(Project, ProjectLink)
    case customLabel(String)
    case allLinks

    var id: String {
        switch self {
        case .appStore(let project):
            "appStore-\(project.id.uuidString)"
        case .usefulLink(let project, let link):
            "usefulLink-\(project.id.uuidString)-\(link.id.uuidString)"
        case .customLabel(let label):
            "customLabel-\(label)"
        case .allLinks:
            "allLinks"
        }
    }

    var title: String {
        switch self {
        case .appStore:
            "Remove App Store Link?"
        case .usefulLink:
            "Remove Useful Link?"
        case .customLabel:
            "Delete Custom Label?"
        case .allLinks:
            "Disconnect All Links?"
        }
    }

    var message: String {
        switch self {
        case .appStore(let project):
            "This will remove the App Store link from \(project.title)."
        case .usefulLink(let project, let link):
            "This will remove the \(link.label) link from \(project.title)."
        case .customLabel(let label):
            "This will delete the reusable custom label preset “\(label)”. Existing project links using that label will stay unchanged."
        case .allLinks:
            "This will remove every App Store and useful link from all projects."
        }
    }
}
