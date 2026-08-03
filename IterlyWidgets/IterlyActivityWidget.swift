//
//  IterlyActivityWidget.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import AppIntents
import SwiftUI
import WidgetKit
import IterlyCore

struct IterlyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: ActivityWidgetKind.identifier,
            intent: SelectProjectsIntent.self,
            provider: ActivityWidgetProvider()
        ) { entry in
            ActivityWidgetView(entry: entry)
        }
        .configurationDisplayName("Activity")
        .description("Track your project activity streak and see the heatmap at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
