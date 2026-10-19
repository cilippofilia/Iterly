//
//  PhantomTabBarInset.swift
//  Iterly
//

import CoreGraphics

/// The extra bottom inset `TabView` gives its tab content while the adaptive sidebar overlay
/// is open, even though no tab bar is shown. See `StableTabBottomInsetModifier`.
enum PhantomTabBarInset {
    /// - Parameters:
    ///   - contentBottomInset: The bottom safe-area inset the tab content sees.
    ///   - rootBottomInset: The bottom safe-area inset of the root `TabView`, or `nil` if unknown.
    ///   - isSidebarLayout: Whether tabs are shown as a sidebar rather than a bottom tab bar.
    ///     When `false`, any difference is a real tab bar and is kept.
    /// - Returns: The amount to cancel out, never negative.
    static func amount(contentBottomInset: CGFloat, rootBottomInset: CGFloat?, isSidebarLayout: Bool) -> CGFloat {
        guard isSidebarLayout, let rootBottomInset else { return 0 }
        return max(0, contentBottomInset - rootBottomInset)
    }
}
