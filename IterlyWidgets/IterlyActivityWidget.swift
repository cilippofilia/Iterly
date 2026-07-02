//
//  IterlyActivityWidget.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import SwiftUI
import WidgetKit
import IterlyCore

struct IterlyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: ActivityWidgetKind.identifier, provider: ActivityWidgetProvider()) { entry in
            ActivityWidgetView(entry: entry)
        }
        .configurationDisplayName("Activity")
        .description("Track your project activity streak and see the heatmap at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
