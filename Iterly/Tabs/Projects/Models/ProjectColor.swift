//
//  ProjectColor.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

enum ProjectColor: String, CaseIterable, Codable {
    case accentColor
    case blue
    case teal
    case green
    case yellow
    case orange
    case red
    case pink
    case purple
    case indigo
    case gray
    case brown
    case mint
    case cyan

    var color: Color {
        switch self {
        case .accentColor:
            return .accentColor
        case .blue:
            return .blue
        case .teal:
            return .teal
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .orange:
            return .orange
        case .red:
            return .red
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .indigo:
            return .indigo
        case .gray:
            return .gray
        case .brown:
            return .brown
        case .mint:
            return .mint
        case .cyan:
            return .cyan
        }
    }
}
