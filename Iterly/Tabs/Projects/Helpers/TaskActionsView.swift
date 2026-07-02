//
//  TaskActionsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI
import IterlyCore

struct TaskActionsView: View {
    let project: Project
    @Binding var showBrainstormSheet: Bool

    var body: some View {
        HStack {
            PrimaryCapsuleActionButton(
                title: "Brainstorm",
                systemImage: "brain",
                action: {
                    showBrainstormSheet = true
                }
            )

            NavigationLink(value: project) {
                Label("Go to Project", systemImage: "folder")
                    .secondaryCapsuleButtonStyle()
            }
            .foregroundStyle(.white)
        }
    }
}
