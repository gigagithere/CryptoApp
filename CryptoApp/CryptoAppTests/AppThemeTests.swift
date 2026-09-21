//
//  AppThemeTests.swift
//  CryptoAppTests
//

import SwiftUI
import Testing
@testable import CryptoApp

struct AppThemeTests {
    @Test func systemFollowsTheDevice() {
        #expect(AppTheme.system.colorScheme == nil)
    }

    @Test func lightAndDarkForceTheirScheme() {
        #expect(AppTheme.light.colorScheme == .light)
        #expect(AppTheme.dark.colorScheme == .dark)
    }

    /// The choice is stored by raw value, so these must not change.
    @Test func storedValuesAreStable() {
        #expect(AppTheme(rawValue: "system") == .system)
        #expect(AppTheme(rawValue: "light") == .light)
        #expect(AppTheme(rawValue: "dark") == .dark)
    }
}
