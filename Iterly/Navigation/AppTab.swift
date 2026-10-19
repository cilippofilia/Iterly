//
//  AppTab.swift
//  Iterly
//

import Foundation

/// The top-level tabs of the app. The raw value doubles as the `iterly://` deep-link host
/// and as the `@SceneStorage` representation.
enum AppTab: String, Hashable, CaseIterable {
    case dashboard
    case projects
    case activity
    case settings

    /// Creates a tab from an `iterly://<tab>` URL; returns `nil` for any other URL.
    init?(deepLink url: URL) {
        guard url.scheme?.lowercased() == "iterly",
              let host = url.host(),
              let tab = AppTab(rawValue: host.lowercased())
        else { return nil }
        self = tab
    }
}
