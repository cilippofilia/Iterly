//
//  ModelContext+WidgetReload.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/07/2026.
//

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
