//
//  ActivityDaySummary.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation

public struct ActivityDaySummary: Identifiable, Hashable, Sendable {
    public let date: Date
    public let count: Int
    public let projectCount: Int
    public let taskCount: Int
    public let intensityLevel: Int

    public init(date: Date, count: Int, projectCount: Int, taskCount: Int, intensityLevel: Int) {
        self.date = date
        self.count = count
        self.projectCount = projectCount
        self.taskCount = taskCount
        self.intensityLevel = intensityLevel
    }

    public var id: Date {
        date
    }

    public var isEmpty: Bool {
        count == 0
    }
}
