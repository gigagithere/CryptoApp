//
//  CryptoAppUITests.swift
//  CryptoAppUITests
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import XCTest

/// Runs the real app on sample data (`-uiTesting`): no network, no Firebase login.
@MainActor
final class CryptoAppUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Pin the locale: this test asserts on English strings, and the app is now localized
        // (Localizable.xcstrings, PL+EN) — without this it fails on a Polish-locale simulator.
        app.launchArguments = ["-uiTesting", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    /// The tab bar slides back in after leaving a pushed screen, so wait until it can be tapped.
    private func openTab(_ name: String) {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
        expectation(for: NSPredicate(format: "isHittable == true"), evaluatedWith: tab)
        waitForExpectations(timeout: 5)
        tab.tap()
    }

    /// One pass over the main flows: browse, search, coin detail, trade sheet, portfolio, settings.
    func testBrowseTradeAndPortfolio() {
        // Home lists the sample coins, and Bitcoin is a favorite in the sample data
        let bitcoin = app.buttons["Bitcoin, BTC, rank 1"]
        XCTAssertTrue(bitcoin.waitForExistence(timeout: 15), "Home never showed the sample coins")
        XCTAssertTrue(app.buttons["Ethereum, ETH, rank 2"].exists)
        XCTAssertTrue(app.buttons["Remove from favorites"].exists)

        // Searching narrows the list, clearing brings it back
        let search = app.searchFields.firstMatch
        search.tap()
        if !app.keyboards.firstMatch.waitForExistence(timeout: 3) {
            search.tap() // the first tap can only move the field up; the second one focuses it
        }
        search.typeText("sol")
        XCTAssertTrue(app.buttons["Solana, SOL, rank 5"].waitForExistence(timeout: 5))
        XCTAssertFalse(bitcoin.exists)
        search.buttons["Clear text"].tap()
        XCTAssertTrue(bitcoin.waitForExistence(timeout: 5))
        // Leave search: its keyboard would otherwise cover the tab bar for the rest of the test
        app.buttons["Close"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))

        // A coin opens its detail screen, and the buy sheet opens and cancels
        bitcoin.tap()
        XCTAssertTrue(app.staticTexts["Overview"].waitForExistence(timeout: 5))
        // Buy is pinned at the bottom, reachable without scrolling
        let buy = app.buttons["Buy"].firstMatch
        XCTAssertTrue(buy.isHittable, "Buy should be visible without scrolling")
        buy.tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields.firstMatch.exists, "the quantity field is missing")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForNonExistence(timeout: 5), "the sheet did not close")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(bitcoin.waitForExistence(timeout: 5), "back did not return to the list")

        // Portfolio shows the sample holdings
        openTab("Portfolio")
        let total = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Total Portfolio Value'")).firstMatch
        XCTAssertTrue(total.waitForExistence(timeout: 10))
        let holdings = app.buttons["Current Holdings, 2 holdings"]
        XCTAssertTrue(holdings.exists)
        holdings.tap()
        XCTAssertTrue(app.navigationBars["Current Holdings"].waitForExistence(timeout: 5))
        // Selling opens the trade sheet instead of selling everything blindly
        app.buttons["Sell BTC"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Your Holdings"].exists)
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForNonExistence(timeout: 5), "the sheet did not close")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Current Holdings"].waitForNonExistence(timeout: 5), "back did not leave Current Holdings")

        // Profile: switch the appearance
        openTab("Profile")
        let dark = app.segmentedControls.buttons["Dark"]
        XCTAssertTrue(dark.waitForExistence(timeout: 5))
        dark.tap()
        XCTAssertTrue(dark.isSelected)

        // Logging out asks first. On iOS 26 the dialog is a popover next to the button
        // with no Cancel button: tapping outside dismisses it and keeps you signed in
        app.buttons["Log Out"].tap()
        let question = app.staticTexts["Log out of CryptoApp?"]
        XCTAssertTrue(question.waitForExistence(timeout: 5))
        app.staticTexts["Appearance"].tap()
        XCTAssertTrue(question.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Log Out"].exists)
    }
}
