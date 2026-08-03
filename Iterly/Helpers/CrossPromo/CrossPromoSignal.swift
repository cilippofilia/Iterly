//
//  CrossPromoSignal.swift
//  Iterly
//

import Foundation

/// Bumped on notable user actions (a new task, a new subtask, a new project, or a task's or
/// project's status changing) so `ContentView` can show a Billboard cross-promo interstitial
/// every 3rd bump, regardless of which tab the action happened in.
@MainActor
@Observable
final class CrossPromoSignal {
    private(set) var count = 0

    func bump() {
        count += 1
    }
}
