//
//  ProjectsViewModel.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI
import IterlyCore

@MainActor
@Observable
final class ProjectsViewModel {
    func splitProjects(_ projects: [Project]) -> (active: [Project], closed: [Project]) {
        (
            active: projects.filter { $0.status != .closed },
            closed: projects.filter { $0.status == .closed }
        )
    }
}
