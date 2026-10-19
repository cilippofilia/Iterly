//
//  AppTabTests.swift
//  IterlyTests
//

import Foundation
import Testing
@testable import Iterly

@MainActor
struct AppTabTests {
    @Test func activityDeepLinkMapsToActivityTab() {
        #expect(AppTab(deepLink: URL(string: "iterly://activity")!) == .activity)
    }

    @Test(arguments: ["iterly://dashboard", "iterly://projects", "iterly://settings"])
    func everyTabHasADeepLink(_ raw: String) {
        let url = URL(string: raw)!
        let tab = AppTab(deepLink: url)
        #expect(tab != nil)
        #expect(tab?.rawValue == url.host())
    }

    @Test(arguments: ["iterly://nope", "https://activity", "iterly:"])
    func unknownLinksAreIgnored(_ raw: String) {
        #expect(AppTab(deepLink: URL(string: raw)!) == nil)
    }

    @Test func shareURLUsesRealAppID() {
        let viewModel = SettingsViewModel()
        #expect(viewModel.appShareURL?.absoluteString == "https://apps.apple.com/app/id6760037639")
        #expect(viewModel.appStoreReviewURL?.absoluteString == "https://apps.apple.com/app/id6760037639?action=write-review")
    }
}
