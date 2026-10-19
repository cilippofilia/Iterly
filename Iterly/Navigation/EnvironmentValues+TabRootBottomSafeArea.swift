//
//  EnvironmentValues+TabRootBottomSafeArea.swift
//  Iterly
//

import SwiftUI

extension EnvironmentValues {
    /// The bottom safe-area inset measured on the root `TabView`, outside any tab content.
    /// Unlike the inset tab content sees, it doesn't grow while the sidebar overlay is open.
    /// `nil` when no ancestor measured it (e.g. previews). Sheets inherit it from the
    /// presenting view, so it doesn't describe a sheet's own safe area.
    @Entry var tabRootBottomSafeArea: CGFloat?
}
