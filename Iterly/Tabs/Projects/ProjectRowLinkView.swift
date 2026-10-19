//
//  ProjectRowLinkView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI
import IterlyCore

struct ProjectRowLinkView: View {
    let project: Project
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NavigationLink(value: project) {
            ProjectRowView(
                title: project.title,
                projectType: project.type,
                statusTitle: project.status.title,
                statusColor: project.status.backgroundColor,
                currentRelease: project.currentRelease,
                tasks: project.topLevelTasks,
                blockedAmount: project.blockedAmount,
                inProgressAmount: project.inProgressAmount,
                doneAmount: project.doneAmount
            )
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                ProjectPinButton(isPinned: project.isPinned, action: onTogglePin)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                ProjectDeleteButton(action: onDelete)
                    .tint(.red)
            }
            .contextMenu {
                ProjectPinButton(isPinned: project.isPinned, action: onTogglePin)
                ProjectDeleteButton(action: onDelete)
            }
        }
        .buttonStyle(.plain)
    }
}
