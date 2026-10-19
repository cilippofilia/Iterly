//
//  ProjectPinButton.swift
//  Iterly
//

import SwiftUI

/// Pin/unpin action shared by a project row's swipe actions and context menu.
struct ProjectPinButton: View {
    let isPinned: Bool
    let action: () -> Void

    var body: some View {
        Button(isPinned ? "Unpin" : "Pin", systemImage: "pin", action: action)
    }
}
