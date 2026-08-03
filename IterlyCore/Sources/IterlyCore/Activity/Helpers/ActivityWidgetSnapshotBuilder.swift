//
//  ActivityWidgetSnapshotBuilder.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 02/07/2026.
//

import Foundation
import SwiftData

/// Builds the widget's activity payload directly from the shared SwiftData store —
/// used by the widget extension's `TimelineProvider`, independent of any UI-selected range.
public enum ActivityWidgetSnapshotBuilder {
    /// Wide enough that no realistic streak or year-style heatmap gets truncated.
    public static let windowDays = 371

    @MainActor
    public static func makeSnapshot(
        modelContext: ModelContext,
        now: Date = .now,
        selectedProjectIDs: [UUID] = []
    ) throws -> ActivityWidgetSnapshot {
        let projects = try modelContext.fetch(FetchDescriptor<Project>())
        let tasks = try modelContext.fetch(FetchDescriptor<ProjectTask>())
        let calendar = ActivityStreakCalculator.makeActivityCalendar()

        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        let start = calendar.date(byAdding: .day, value: -windowDays, to: end) ?? end

        let events = ActivityDataProvider().events(
            for: .twelveMonths,
            now: now,
            projects: projects,
            tasks: tasks,
            calendar: calendar
        )

        let summaries = ActivityStreakCalculator.makeDaySummaries(
            events: events,
            from: start,
            through: end,
            calendar: calendar
        )

        let displayStart = calendar.dateInterval(of: .weekOfYear, for: start)?.start ?? start
        let paddedSummaries = ActivityStreakCalculator.makeDaySummaries(
            events: events,
            from: displayStart,
            through: end,
            calendar: calendar
        )

        let weeks = stride(from: 0, to: paddedSummaries.count, by: 7).map { index in
            Array(paddedSummaries[index ..< min(index + 7, paddedSummaries.count)])
        }

        let streak = ActivityStreakCalculator.latestStreak(in: summaries, calendar: calendar)
        let hasLoggedToday = summaries.last.map { calendar.isDate($0.date, inSameDayAs: now) && $0.count > 0 } ?? false
        let totalCount = summaries.reduce(0) { $0 + $1.count }
        let busiestDay = summaries.max { lhs, rhs in
            if lhs.count != rhs.count {
                return lhs.count < rhs.count
            }
            return lhs.date < rhs.date
        }

        let recentProjects = projectSummaries(from: projects, selectedProjectIDs: selectedProjectIDs)

        return ActivityWidgetSnapshot(
            weeks: weeks,
            streak: streak,
            hasLoggedToday: hasLoggedToday,
            totalCount: totalCount,
            busiestDay: busiestDay,
            recentProjects: recentProjects,
            isCustomProjectSelection: !selectedProjectIDs.isEmpty,
            generatedAt: now
        )
    }

    /// With no explicit selection, falls back to the 4 most recently updated, non-closed
    /// projects. With a selection, shows exactly those projects (up to 4) in the order chosen.
    private static func projectSummaries(
        from projects: [Project],
        selectedProjectIDs: [UUID]
    ) -> [ActivityWidgetProjectSummary] {
        let source: [Project]
        if selectedProjectIDs.isEmpty {
            source = projects
                .filter { $0.status != .closed }
                .sorted { $0.lastUpdated > $1.lastUpdated }
        } else {
            let projectsByID = Dictionary(uniqueKeysWithValues: projects.map { ($0.id, $0) })
            source = selectedProjectIDs.compactMap { projectsByID[$0] }
        }

        return source.prefix(4).map { project in
            ActivityWidgetProjectSummary(
                id: project.id,
                title: project.title,
                type: project.type,
                status: project.status,
                progress: project.doneAmount,
                lastUpdated: project.lastUpdated
            )
        }
    }
}
