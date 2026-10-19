//
//  PhantomTabBarInsetTests.swift
//  IterlyTests
//

import CoreGraphics
import Testing
@testable import Iterly

struct PhantomTabBarInsetTests {
    @Test func sidebarOverlayInsetIsCancelled() {
        let amount = PhantomTabBarInset.amount(contentBottomInset: 83, rootBottomInset: 34, isSidebarLayout: true)
        #expect(amount == 49)
    }

    @Test func matchingInsetsNeedNoCorrection() {
        let amount = PhantomTabBarInset.amount(contentBottomInset: 34, rootBottomInset: 34, isSidebarLayout: true)
        #expect(amount == 0)
    }

    @Test func realTabBarInsetIsKept() {
        let amount = PhantomTabBarInset.amount(contentBottomInset: 83, rootBottomInset: 34, isSidebarLayout: false)
        #expect(amount == 0)
    }

    @Test func unknownRootInsetNeedsNoCorrection() {
        let amount = PhantomTabBarInset.amount(contentBottomInset: 83, rootBottomInset: nil, isSidebarLayout: true)
        #expect(amount == 0)
    }

    @Test func smallerContentInsetIsNeverNegative() {
        let amount = PhantomTabBarInset.amount(contentBottomInset: 0, rootBottomInset: 34, isSidebarLayout: true)
        #expect(amount == 0)
    }
}
