//
//  View+AppNavigationDestinations.swift
//  Iterly
//

import SwiftUI
import IterlyCore

extension View {
    /// Registers the app's value-based navigation destinations.
    /// Apply exactly once per `NavigationStack` root.
    func appNavigationDestinations(onProjectDelete: @escaping () -> Void = {}) -> some View {
        navigationDestination(for: Project.self) { project in
            ProjectDetailView(project: project, onDelete: onProjectDelete)
        }
        .navigationDestination(for: ProjectTask.self) { task in
            TaskDetailView(task: task)
        }
        .navigationDestination(for: TaskListRoute.self) { route in
            TaskListRouteView(route: route)
        }
    }
}
