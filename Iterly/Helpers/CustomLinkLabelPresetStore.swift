//
//  CustomLinkLabelPresetStore.swift
//  Iterly
//
//  Created by Filippo Cilia on 31/03/2026.
//

import Foundation

struct CustomLinkLabelPresetStore {
    static let storageKey = "project.customLinkLabelPresets"

    enum StoreError: LocalizedError {
        case unableToEncode

        var errorDescription: String? {
            switch self {
            case .unableToEncode:
                "Unable to update custom labels."
            }
        }
    }

    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = Self.storageKey
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> [String] {
        guard let data = defaults.string(forKey: key)?.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return normalized(decoded)
    }

    func mergeAndSave(_ presets: [String]) throws {
        try save(load() + presets)
    }

    func delete(_ label: String) throws {
        let updatedPresets = load().filter {
            $0.compare(label, options: [.caseInsensitive, .diacriticInsensitive]) != .orderedSame
        }
        try save(updatedPresets)
    }

    private func save(_ presets: [String]) throws {
        let normalizedPresets = normalized(presets)
        guard let data = try? JSONEncoder().encode(normalizedPresets),
              let encodedPresets = String(data: data, encoding: .utf8) else {
            throw StoreError.unableToEncode
        }

        defaults.set(encodedPresets, forKey: key)
    }

    private func normalized(_ presets: [String]) -> [String] {
        var uniquePresets: [String] = []

        for preset in presets {
            let trimmedPreset = preset.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedPreset.isEmpty == false else { continue }

            let alreadyIncluded = uniquePresets.contains {
                $0.compare(trimmedPreset, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            }
            if alreadyIncluded == false {
                uniquePresets.append(trimmedPreset)
            }
        }

        return uniquePresets
    }
}
