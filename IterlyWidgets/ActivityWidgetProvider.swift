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
            let now = Date.now
            let snapshot = await currentSnapshot()
            let calendar = Calendar.autoupdatingCurrent
            let nextMidnight = calendar.nextDate(
                after: now,
                matching: DateComponents(hour: 0, minute: 0),
                matchingPolicy: .nextTime
            ) ?? now.addingTimeInterval(86_400)

            var entries = [ActivityWidgetEntry(date: now, snapshot: snapshot)]

            // The streak is alive but still unlogged today: schedule the flame's remaining
            // six-hourly cooldown steps so it visibly burns out over the day without needing
            // the app to reopen and refresh the timeline.
            if snapshot.streak > 0, !snapshot.hasLoggedToday {
                var stepDate = now
                while let next = calendar.date(byAdding: .hour, value: 6, to: stepDate), next < nextMidnight {
                    entries.append(ActivityWidgetEntry(date: next, snapshot: snapshot))
                    stepDate = next
                }
            }

            completion(Timeline(entries: entries, policy: .after(nextMidnight)))
        }
    }

    @MainActor
    private func currentEntry() async -> ActivityWidgetEntry {
        ActivityWidgetEntry(date: .now, snapshot: await currentSnapshot())
    }

    @MainActor
    private func currentSnapshot() async -> ActivityWidgetSnapshot {
        do {
            let container = SharedModelContainer.make()
            return try ActivityWidgetSnapshotBuilder.makeSnapshot(modelContext: container.mainContext)
        } catch {
            return .empty
        }
    }
}
