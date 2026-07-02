//
//  ActivityWidgetProvider.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import SwiftData
import WidgetKit
import IterlyCore

struct ActivityWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActivityWidgetEntry {
        ActivityWidgetEntry(date: .now, snapshot: .samplePlaceholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (ActivityWidgetEntry) -> Void) {
        if context.isPreview {
            completion(ActivityWidgetEntry(date: .now, snapshot: .samplePlaceholder))
            return
        }

        Task { @MainActor in
            completion(await currentEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ActivityWidgetEntry>) -> Void) {
        Task { @MainActor in
            let entry = await currentEntry()
            let nextMidnight = Calendar.autoupdatingCurrent.nextDate(
                after: .now,
                matching: DateComponents(hour: 0, minute: 0),
                matchingPolicy: .nextTime
            ) ?? .now.addingTimeInterval(86_400)

            completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
        }
    }

    @MainActor
    private func currentEntry() async -> ActivityWidgetEntry {
        do {
            let container = SharedModelContainer.make()
            let snapshot = try ActivityWidgetSnapshotBuilder.makeSnapshot(modelContext: container.mainContext)
            return ActivityWidgetEntry(date: .now, snapshot: snapshot)
        } catch {
            return ActivityWidgetEntry(date: .now, snapshot: .empty)
        }
    }
}
