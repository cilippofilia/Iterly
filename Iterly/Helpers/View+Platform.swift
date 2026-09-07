//
//  View+Platform.swift
//  Iterly
//
//  Created by Filippo Cilia on 07/09/2026.
//

import SwiftUI

/// Cross-platform wrappers for modifiers that only exist on iOS, so views don't
/// need to scatter `#if os` checks. Each one is a no-op (or the closest native
/// equivalent) on macOS.
extension View {
    /// `.navigationBarTitleDisplayMode(.inline)` on iOS; no-op on macOS.
    func inlineNavigationBarTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// `.fullScreenCover` on iOS; a `.sheet` on macOS, where full-screen covers don't exist.
    func platformFullScreenCover<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(item: item, content: content)
        #else
        sheet(item: item, content: content)
        #endif
    }

    /// Gives sheet content a sensible minimum size on macOS, where sheets size to fit
    /// and can otherwise collapse; no-op on iOS, where covers fill the screen.
    func macSheetMinimumSize() -> some View {
        #if os(macOS)
        frame(minWidth: 480, minHeight: 600)
        #else
        self
        #endif
    }

    /// `.listRowSpacing` on iOS; no-op on macOS, where the modifier doesn't exist.
    func platformListRowSpacing(_ spacing: CGFloat) -> some View {
        #if os(iOS)
        listRowSpacing(spacing)
        #else
        self
        #endif
    }

    /// `.insetGrouped` on iOS; `.inset` on macOS, which has no inset-grouped list style.
    func platformInsetGroupedListStyle() -> some View {
        #if os(iOS)
        listStyle(.insetGrouped)
        #else
        listStyle(.inset)
        #endif
    }

    /// URL keyboard with autocapitalization off on iOS; no-op on macOS, which has no software keyboard.
    func urlTextFieldConfiguration() -> some View {
        #if os(iOS)
        keyboardType(.URL)
            .textInputAutocapitalization(.never)
        #else
        self
        #endif
    }

    /// Per-word autocapitalization on iOS; no-op on macOS.
    func wordsTextInputAutocapitalization() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.words)
        #else
        self
        #endif
    }
}

extension View {
    /// Keeps scrolling content at a readable width on wide layouts (iPad, macOS)
    /// instead of stretching edge to edge; no effect on compact widths.
    func readableContentWidth() -> some View {
        frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
    }
}

extension ToolbarItemPlacement {
    /// `.topBarTrailing` on iOS; `.primaryAction` on macOS, where there is no navigation bar.
    static var platformTopBarTrailing: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .primaryAction
        #endif
    }

    /// `.topBarLeading` on iOS; `.cancellationAction` on macOS.
    static var platformTopBarLeading: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .cancellationAction
        #endif
    }
}
