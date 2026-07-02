//
//  ActivityWidgetKind.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation

/// The widget `kind` identifier shared between `IterlyActivityWidget`'s `StaticConfiguration`
/// and the app's `WidgetCenter.reloadTimelines(ofKind:)` calls, so the two can't drift apart.
public enum ActivityWidgetKind {
    public static let identifier = "IterlyActivityWidget"
}
