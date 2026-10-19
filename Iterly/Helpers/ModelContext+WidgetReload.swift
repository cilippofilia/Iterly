//
//  ModelContext+WidgetReload.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/07/2026.
//

import OSLog
import SwiftData
import WidgetKit
import IterlyCore

extension ModelContext {
    /// Saves pending changes and reloads the activity widget's timeline so Home Screen
    /// widgets reflect the change without waiting for the next scheduled midnight refresh.
    func saveAndReloadActivityWidget() throws {
        try save()
        WidgetCenter.shared.reloadTimelines(ofKind: ActivityWidgetKind.identifier)
    }
}

extension ModelContext {
    /// Saves for inline edits where SwiftData autosave will retry later. Failures are logged,
    /// not shown; user-initiated save or delete paths must surface an alert instead.
    func saveLoggingFailure(_ action: String) {
        do {
            try saveAndReloadActivityWidget()
        } catch {
            Logger(subsystem: "cilia.filippo.Iterly", category: "Persistence")
                .error("Failed to save \(action, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
}
