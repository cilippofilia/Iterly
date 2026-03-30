//
//  ActivityDataProvider.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

struct ActivityDataProvider: ActivityDataProviding {
    func events(
        for range: ActivityRange,
        now: Date,
        projects: [Project],
        tasks: [ProjectTask],
        calendar: Calendar
    ) -> [ActivityEvent] {
        let interval = range.dateInterval(relativeTo: now, calendar: calendar)

        return (projectEvents(in: interval, from: projects, calendar: calendar)
            + taskEvents(in: interval, from: tasks, calendar: calendar))
            .sorted { lhs, rhs in
                if lhs.date != rhs.date {
                    return lhs.date < rhs.date
                }

                if lhs.kind != rhs.kind {
                    return lhs.kind.rawValue < rhs.kind.rawValue
                }

                return lhs.title < rhs.title
            }
    }

    private func projectEvents(
        in interval: DateInterval,
        from projects: [Project],
        calendar: Calendar
    ) -> [ActivityEvent] {
        projects.flatMap { project in
            let createdEvent = makeProjectCreationEvent(
                for: project,
                in: interval,
                calendar: calendar
            )
            let updatedEvent = makeProjectUpdateEvent(
                for: project,
                in: interval,
                calendar: calendar
            )

            return [createdEvent, updatedEvent].compactMap { $0 }
        }
    }

    private func taskEvents(
        in interval: DateInterval,
        from tasks: [ProjectTask],
        calendar: Calendar
    ) -> [ActivityEvent] {
        tasks.flatMap { task in
            let createdEvent = makeTaskCreationEvent(
                for: task,
                in: interval,
                calendar: calendar
            )
            let updatedEvent = makeTaskUpdateEvent(
                for: task,
                in: interval,
                calendar: calendar
            )

            return [createdEvent, updatedEvent].compactMap { $0 }
        }
    }

    private func makeTaskCreationEvent(
        for task: ProjectTask,
        in interval: DateInterval,
        calendar: Calendar
    ) -> ActivityEvent? {
        guard interval.contains(task.creationDate) else {
            return nil
        }

        return ActivityEvent(
            date: calendar.startOfDay(for: task.creationDate),
            kind: .task,
            title: task.title,
            context: task.parentTask == nil ? task.project.title : "Subtask in \(task.project.title)"
        )
    }

    private func makeTaskUpdateEvent(
        for task: ProjectTask,
        in interval: DateInterval,
        calendar: Calendar
    ) -> ActivityEvent? {
        guard let lastUpdated = task.lastUpdated else {
            return nil
        }

        guard interval.contains(lastUpdated) else {
            return nil
        }

        guard lastUpdated != task.creationDate else {
            return nil
        }

        return ActivityEvent(
            date: calendar.startOfDay(for: lastUpdated),
            kind: .task,
            title: task.title,
            context: task.parentTask == nil ? "Updated in \(task.project.title)" : "Updated subtask in \(task.project.title)"
        )
    }

    private func makeProjectCreationEvent(
        for project: Project,
        in interval: DateInterval,
        calendar: Calendar
    ) -> ActivityEvent? {
        guard interval.contains(project.creationDate) else {
            return nil
        }

        return ActivityEvent(
            date: calendar.startOfDay(for: project.creationDate),
            kind: .project,
            title: project.title,
            context: "Created"
        )
    }

    private func makeProjectUpdateEvent(
        for project: Project,
        in interval: DateInterval,
        calendar: Calendar
    ) -> ActivityEvent? {
        guard interval.contains(project.lastUpdated) else {
            return nil
        }

        guard project.lastUpdated != project.creationDate else {
            return nil
        }

        return ActivityEvent(
            date: calendar.startOfDay(for: project.lastUpdated),
            kind: .project,
            title: project.title,
            context: project.status.title
        )
    }
}
