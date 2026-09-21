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
        app.launchArguments = ["-uiTesting"]
        app.launch()
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

        // A coin opens its detail screen, and the buy sheet opens and cancels
        bitcoin.tap()
        XCTAssertTrue(app.staticTexts["Overview"].waitForExistence(timeout: 5))
        app.buttons["Buy"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields.firstMatch.exists, "the quantity field is missing")
        app.buttons["Cancel"].tap()
        app.navigationBars.buttons.firstMatch.tap()

        // Portfolio shows the sample holdings
        app.tabBars.buttons["Portfolio"].tap()
        let total = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Total Portfolio Value'")).firstMatch
        XCTAssertTrue(total.waitForExistence(timeout: 10))
        let holdings = app.buttons["Current Holdings, 2 holdings"]
        XCTAssertTrue(holdings.exists)
        holdings.tap()
        XCTAssertTrue(app.navigationBars["Current Holdings"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()

        // Profile: switch the appearance
        app.tabBars.buttons["Profile"].tap()
        let dark = app.segmentedControls.buttons["Dark"]
        XCTAssertTrue(dark.waitForExistence(timeout: 5))
        dark.tap()
        XCTAssertTrue(dark.isSelected)
        XCTAssertTrue(app.buttons["Logout"].exists)
    }
}
