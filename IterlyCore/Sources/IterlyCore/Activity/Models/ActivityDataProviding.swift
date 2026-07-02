import Foundation

public protocol ActivityDataProviding {
    func events(
        for range: ActivityRange,
        now: Date,
        projects: [Project],
        tasks: [ProjectTask],
        calendar: Calendar
    ) -> [ActivityEvent]
}
