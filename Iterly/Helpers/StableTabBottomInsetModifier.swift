//
//  StableTabBottomInsetModifier.swift
//  Iterly
//

import SwiftUI

/// `.safeAreaInset(edge: .bottom)` for tab content that stays put while the adaptive
/// sidebar is open.
///
/// When the sidebar is presented as an overlay (e.g. the iPhone Duo inner display), the
/// `TabView` adds a tab-bar-height bottom inset (34 → 83pt) to the tab content even though
/// no tab bar is shown, so a plain `.safeAreaInset` jumps up. On iOS 27+ in regular width,
/// where `adaptiveTabBarPlacement()` makes tabs a sidebar rather than a bottom bar, the inset
/// content is offset back down by the difference from the root `TabView`'s inset. Compact
/// width, and iOS 26 (where large iPhones in landscape still show a tab bar), keep the inset.
struct StableTabBottomInsetModifier<InsetContent: View>: ViewModifier {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.tabRootBottomSafeArea) private var tabRootBottomSafeArea

    @State private var bottomSafeArea: CGFloat = 0

    @ViewBuilder var insetContent: InsetContent

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                insetContent
                    .offset(y: phantomInset)
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.safeAreaInsets.bottom
            } action: { newValue in
                bottomSafeArea = newValue
            }
    }

    /// The extra bottom inset the sidebar overlay adds, or 0 where it can't be a phantom.
    private var phantomInset: CGFloat {
        PhantomTabBarInset.amount(
            contentBottomInset: bottomSafeArea,
            rootBottomInset: tabRootBottomSafeArea,
            isSidebarLayout: isSidebarLayout
        )
    }

    /// Mirrors `adaptiveTabBarPlacement()`: only iOS 27+ prefers the sidebar in regular width.
    private var isSidebarLayout: Bool {
        #if os(iOS)
        if #available(iOS 27, *) {
            horizontalSizeClass == .regular
        } else {
            false
        }
        #else
        false
        #endif
    }
}

extension View {
    /// A bottom `.safeAreaInset` for tab root content that doesn't shift when the sidebar
    /// overlay opens. See `StableTabBottomInsetModifier`.
    func stableTabBottomInset<InsetContent: View>(
        @ViewBuilder content: () -> InsetContent
    ) -> some View {
        modifier(StableTabBottomInsetModifier(insetContent: content))
    }
}
