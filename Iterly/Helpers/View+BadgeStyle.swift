//
//  BadgeStyleModifier.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/03/2026.
//

import SwiftUI

private struct BadgeStyleModifier: ViewModifier {
    @Environment(\.self) private var environment
    @Environment(\.colorScheme) private var colorScheme
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .foregroundStyle(foregroundColor)
            .font(.caption2)
            .bold()
            .contentTransition(.numericText())
            .padding(4)
            .background(backgroundColor.gradient)
            .clipShape(.rect(cornerRadius: 4, style: .continuous))
    }

    private var foregroundColor: Color {
        let resolved = backgroundColor.resolve(in: environment)
        // Blend semi-transparent backgrounds with the base surface so luminance reflects actual rendering.
        let baseResolved = (colorScheme == .dark ? Color.black : .white).resolve(in: environment)
        let alpha = resolved.opacity
        let effectiveRed = (resolved.red * alpha) + (baseResolved.red * (1 - alpha))
        let effectiveGreen = (resolved.green * alpha) + (baseResolved.green * (1 - alpha))
        let effectiveBlue = (resolved.blue * alpha) + (baseResolved.blue * (1 - alpha))
        let luminance = (0.2126 * effectiveRed) + (0.7152 * effectiveGreen) + (0.0722 * effectiveBlue)
        return luminance < 0.6 ? .white : .black
    }
}

private struct PrimaryCapsuleButtonStyleModifier: ViewModifier {
    let foregroundColor: Color
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundColor)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.gradient)
            .clipShape(.capsule)
    }
}

private struct SecondaryCapsuleButtonStyleModifier: ViewModifier {
    let foregroundColor: Color
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundColor)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.gradient)
            .clipShape(.capsule)
    }
}

extension View {
    func badgeStyle(backgroundColor: Color) -> some View {
        modifier(BadgeStyleModifier(backgroundColor: backgroundColor))
    }

    func primaryCapsuleButtonStyle(
        foregroundColor: Color = .white,
        backgroundColor: Color = .blue
    ) -> some View {
        modifier(
            PrimaryCapsuleButtonStyleModifier(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor
            )
        )
    }
    func secondaryCapsuleButtonStyle(
        foregroundColor: Color = .primary,
        backgroundColor: Color = .gray.opacity(0.25)
    ) -> some View {
        modifier(
            SecondaryCapsuleButtonStyleModifier(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor
            )
        )
    }
}
