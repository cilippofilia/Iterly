//
//  SettingsViewModel.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    enum AlertKind: String, Identifiable {
        case sampleDataAdded
        case eraseAllDataConfirmation

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .sampleDataAdded:
                "Sample Data Added"
            case .eraseAllDataConfirmation:
                "Erase All Data?"
            }
        }

        var message: String {
            switch self {
            case .sampleDataAdded:
                "Sample projects and tasks have been added to the app."
            case .eraseAllDataConfirmation:
                "This will permanently remove all projects, tasks, and releases."
            }
        }
    }

    enum ContactOption: String, CaseIterable, Identifiable {
        case reportBug
        case requestFeature
        case otherEnquiry

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .reportBug:
                "Report a bug"
            case .requestFeature:
                "Request a Feature"
            case .otherEnquiry:
                "Other Enquiry"
            }
        }

        var subject: String {
            switch self {
            case .reportBug:
                "Bug Report"
            case .requestFeature:
                "Feature idea"
            case .otherEnquiry:
                ""
            }
        }

        var body: String {
            switch self {
            case .reportBug:
                "Please provide as many details about the bug you encountered as possible - and include screenshots if possible."
            case .requestFeature:
                ""
            case .otherEnquiry:
                ""
            }
        }
    }

    var showCompletedTasks: Bool {
        didSet { userDefaults.set(showCompletedTasks, forKey: Self.showCompletedTasksKey) }
    }
    var highlightOverdueTasks: Bool {
        didSet { userDefaults.set(highlightOverdueTasks, forKey: Self.highlightOverdueTasksKey) }
    }
    var compactProjectCards: Bool {
        didSet { userDefaults.set(compactProjectCards, forKey: Self.compactProjectCardsKey) }
    }

    var showContactOptions: Bool = false
    var activeAlert: AlertKind?

    private let userDefaults: UserDefaults
    private let projectViewModel = ProjectViewModel()
    private let supportEmail = "cilia.filippo.dev@gmail.com"
    private let appShareURLString = "https://apps.apple.com/app/id0000000000"
    private let appName = "Iterly"

    private static let showCompletedTasksKey = "settings.showCompletedTasks"
    private static let highlightOverdueTasksKey = "settings.highlightOverdueTasks"
    private static let compactProjectCardsKey = "settings.compactProjectCards"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.showCompletedTasks = userDefaults.object(forKey: Self.showCompletedTasksKey) as? Bool ?? true
        self.highlightOverdueTasks = userDefaults.object(forKey: Self.highlightOverdueTasksKey) as? Bool ?? true
        self.compactProjectCards = userDefaults.object(forKey: Self.compactProjectCardsKey) as? Bool ?? false
    }

    var currentVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var appShareURL: URL? {
        URL(string: appShareURLString)
    }

    var appShareItem: String {
        "Check out \(appName)"
    }

    var appStoreReviewURL: URL? {
        guard let appShareURL else { return nil }
        return URL(string: "\(appShareURL.absoluteString)?action=write-review")
    }

    func mailURL(for option: ContactOption) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: option.subject),
            URLQueryItem(name: "body", value: option.body)
        ]
        return components.url
    }

    func addSampleData(modelContext: ModelContext) {
        SampleData.insertSample(in: modelContext)
        activeAlert = .sampleDataAdded
    }

    func promptEraseAllData() {
        activeAlert = .eraseAllDataConfirmation
    }

    func eraseAllData(modelContext: ModelContext) {
        projectViewModel.eraseAllData(modelContext: modelContext)
        activeAlert = nil
    }
}
