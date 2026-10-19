//
//  PinToggleResult.swift
//  Iterly
//

/// Outcome of a successful pin toggle attempt.
enum PinToggleResult: Equatable {
    /// The pinned state changed and was saved.
    case toggled
    /// The project was not pinned because the pin limit has been reached.
    case limitReached
}
