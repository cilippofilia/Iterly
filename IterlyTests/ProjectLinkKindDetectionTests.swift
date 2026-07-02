//
//  ProjectLinkKindDetectionTests.swift
//  IterlyTests
//
//  Created by Filippo Cilia on 01/07/2026.
//

import Foundation
import Testing
import IterlyCore
@testable import Iterly

struct ProjectLinkKindDetectionTests {
    @Test func detectsTestFlightJoinURL() {
        let detected = ProjectLinkKind.detected(fromURL: "https://testflight.apple.com/join/AbCd1234")

        #expect(detected == .testflight)
    }

    @Test func detectsTestFlightURLWithoutScheme() {
        let detected = ProjectLinkKind.detected(fromURL: "testflight.apple.com/join/AbCd1234")

        #expect(detected == .testflight)
    }

    @Test func detectionIsCaseInsensitive() {
        let detected = ProjectLinkKind.detected(fromURL: "https://TestFlight.Apple.com/join/AbCd1234")

        #expect(detected == .testflight)
    }

    @Test func doesNotDetectUnrelatedURLs() {
        #expect(ProjectLinkKind.detected(fromURL: "https://github.com/example/repo") == nil)
        #expect(ProjectLinkKind.detected(fromURL: "https://apps.apple.com/gb/app/id6449893371") == nil)
        #expect(ProjectLinkKind.detected(fromURL: "") == nil)
    }

    @Test func draftSwitchesKindForTestFlightURL() {
        var draft = ProjectLinkDraft(kind: .website, url: "https://testflight.apple.com/join/AbCd1234")

        draft.applyDetectedKind()

        #expect(draft.kind == .testflight)
    }

    @Test func draftKeepsCustomKindAndLabel() {
        var draft = ProjectLinkDraft(
            kind: .custom,
            customLabel: "Beta Feedback",
            url: "https://testflight.apple.com/join/AbCd1234"
        )

        draft.applyDetectedKind()

        #expect(draft.kind == .custom)
        #expect(draft.customLabel == "Beta Feedback")
    }

    @Test func draftKeepsKindForUnrecognizedURL() {
        var draft = ProjectLinkDraft(kind: .github, url: "https://github.com/example/repo")

        draft.applyDetectedKind()

        #expect(draft.kind == .github)
    }
}
