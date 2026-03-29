//
//  ProjectRowLinkView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

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
                Button(action: onTogglePin) {
                    Label("Pin", systemImage: "pin")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .buttonStyle(.plain)
    }
}
