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

    // Missing statuses tint `.clear`: a nil tint falls back to the accent color, and macOS
    // still draws a small leading cap for a zero-value bar.
    var body: some View {
        ProgressView(value: inProgressAmount + blockedAmount + doneAmount)
            .tint(doneColor ?? .clear)
            .overlay {
                ProgressView(value: inProgressAmount + blockedAmount)
                    .tint(inProgressColor ?? .clear)
            }
            .overlay {
                ProgressView(value: blockedAmount)
                    .tint(blockedColor ?? .clear)
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
