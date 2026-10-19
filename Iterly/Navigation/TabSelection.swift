//
//  TabSelection.swift
//  Iterly
//

import Observation

/// Per-window selected tab, shared with child views through the environment.
@MainActor
@Observable
final class TabSelection {
    var selected: AppTab

    init(selected: AppTab = .dashboard) {
        self.selected = selected
    }
}
