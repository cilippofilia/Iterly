//
//  TaskSectionsBuilder.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import Foundation
import IterlyCore

struct TaskSectionsBuilder {
    struct Sections {
        let active: [ProjectTask]
        let completed: [ProjectTask]
        let closed: [ProjectTask]
    }

    static func sections(for tasks: [ProjectTask]) -> Sections {
        let sortedTasks = tasks.sortedForDisplay()

        return Sections(
            active: sortedTasks.filter { $0.status != .done && $0.status != .closed },
            completed: sortedTasks.filter { $0.status == .done },
            closed: sortedTasks.filter { $0.status == .closed }
        )
    }
}
