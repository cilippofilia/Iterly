//
//  ProjectRelease.swift
//  Iterly
//
//  Created by Filippo Cilia on 04/03/2026.
//

import Foundation
import SwiftData

@Model
final class ProjectRelease: Identifiable {
    var id: UUID = UUID()
    var version: String = ""
    // Legacy persisted field kept so existing stores continue to open cleanly.
    var build: String = ""
    var appURL: String = ""

    @Relationship(inverse: \Project.currentRelease)
    var project: Project

    init(
        id: UUID = UUID(),
        version: String = "",
        build: String = "",
        appURL: String = "",
        project: Project
    ) {
        self.id = id
        self.version = version
        self.build = build
        self.appURL = appURL
        self.project = project
    }
}
