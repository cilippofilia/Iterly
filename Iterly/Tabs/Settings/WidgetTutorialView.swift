//
//  WidgetTutorialView.swift
//  Iterly
//
//  Created by Filippo Cilia on 03/08/2026.
//

import SwiftUI

struct WidgetTutorialView: View {
    private let steps: [WidgetTutorialStep] = [
        WidgetTutorialStep(
            number: 1,
            title: "Touch and hold the Home Screen",
            description: "Touch and hold an empty area of your Home Screen until the apps start to jiggle."
        ),
        WidgetTutorialStep(
            number: 2,
            title: "Tap the + button",
            description: "Tap the plus button near the top of the screen to open the widget gallery."
        ),
        WidgetTutorialStep(
            number: 3,
            title: "Search for Iterly",
            description: "Type \"Iterly\" in the search field, or scroll the gallery to find it."
        ),
        WidgetTutorialStep(
            number: 4,
            title: "Choose a size",
            description: "Swipe between Small, Medium, and Large to preview the Activity widget, then tap Add Widget."
        ),
        WidgetTutorialStep(
            number: 5,
            title: "Place it and tap Done",
            description: "Drag the widget wherever you'd like on your Home Screen, then tap Done to finish."
        )
    ]

    var body: some View {
        Form {
            Section {
                WidgetTutorialHeaderView()
            }

            Section {
                ForEach(steps) { step in
                    WidgetTutorialStepRow(step: step)
                }
            } header: {
                Text("Add the Iterly widget")
            } footer: {
                Text("Widgets update automatically as you log project activity.")
            }
        }
        .safeAreaPadding(.bottom, 60)
        .navigationTitle("Add a Widget")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WidgetTutorialHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Activity", systemImage: "widget.small.badge.plus")
                .font(.headline)
            Text(
                "Track your project activity streak and see the heatmap at a glance, right from your Home Screen. "
                + "Available in Small, Medium, and Large sizes."
            )
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct WidgetTutorialStep: Identifiable {
    let number: Int
    let title: String
    let description: String

    var id: Int { number }
}

private struct WidgetTutorialStepRow: View {
    let step: WidgetTutorialStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(step.number, format: .number)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.gradient)
                .clipShape(.circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                Text(step.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        WidgetTutorialView()
    }
}
