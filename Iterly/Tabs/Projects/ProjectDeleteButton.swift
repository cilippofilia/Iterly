//
//  ProjectDeleteButton.swift
//  Iterly
//

import SwiftUI

/// Destructive delete action shared by a project row's swipe actions and context menu.
struct ProjectDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button("Delete", systemImage: "trash", role: .destructive, action: action)
    }
}
