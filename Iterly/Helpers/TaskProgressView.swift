//
//  TaskProgressView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI
import IterlyCore

struct TaskProgressView: View {
    let tasks: [ProjectTask]
    let blockedAmount: Double
    let inProgressAmount: Double
    let doneAmount: Double

    var body: some View {
        ProgressView(value: inProgressAmount + blockedAmount + doneAmount)
            .tint(doneColor)
            .overlay {
                ProgressView(value: inProgressAmount + blockedAmount)
                    .tint(inProgressColor)
            }
            .overlay {
                ProgressView(value: blockedAmount)
                    .tint(blockedColor)
            }
    }

    private var doneColor: Color? {
        tasks.first(where: { $0.status == .done })?.status.backgroundColor
    }

    private var inProgressColor: Color? {
        tasks.first(where: { $0.status == .inProgress })?.status.backgroundColor
    }

    private var blockedColor: Color? {
        tasks.first(where: { $0.status == .blocked })?.status.backgroundColor
    }
}
