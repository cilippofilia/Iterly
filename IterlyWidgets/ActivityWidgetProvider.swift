//
//  ActivityWidgetProvider.swift
//  IterlyWidgets
//
//  Created by Filippo Cilia on 02/07/2026.
//

import AppIntents
import SwiftData
import WidgetKit
import IterlyCore

struct ActivityWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ActivityWidgetEntry {
        ActivityWidgetEntry(date: .now, snapshot: .samplePlaceholder)
    }

    func snapshot(for configuration: SelectProjectsIntent, in context: Context) async -> ActivityWidgetEntry {
        if context.isPreview {
            return ActivityWidgetEntry(date: .now, snapshot: .samplePlaceholder)
        }
        return await currentEntry(configuration: configuration)
    }

    func timeline(for configuration: SelectProjectsIntent, in context: Context) async -> Timeline<ActivityWidgetEntry> {
        let now = Date.now
        let snapshot = await currentSnapshot(configuration: configuration)
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

        return Timeline(entries: entries, policy: .after(nextMidnight))
    }

    @MainActor
    private func currentEntry(configuration: SelectProjectsIntent) async -> ActivityWidgetEntry {
        ActivityWidgetEntry(date: .now, snapshot: await currentSnapshot(configuration: configuration))
    }

    @MainActor
    private func currentSnapshot(configuration: SelectProjectsIntent) async -> ActivityWidgetSnapshot {
        do {
            let container = SharedModelContainer.make()
            return try ActivityWidgetSnapshotBuilder.makeSnapshot(
                modelContext: container.mainContext,
                selectedProjectIDs: configuration.selectedProjectIDs
            )
        } catch {
            return .empty
        }
    }
}
