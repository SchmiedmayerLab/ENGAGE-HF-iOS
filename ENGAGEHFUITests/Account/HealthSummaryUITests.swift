//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class HealthSummaryUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--setupTestEnvironment",
            "--setupTestUserMetaData",
            "--useFirebaseEmulator",
            "--skipRemoteNotificationRegistration"
        ]
        app.launch()
        
        try await Task.sleep(for: .seconds(2))
        addNotificatinosUIInterruptionMonitor()
        try await Task.sleep(for: .seconds(0.5))
    }

    
    func testHealthSummaryView() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Home")
        
        app.navigationBars.buttons["Your Account"].assertExists()
        app.navigationBars.buttons["Your Account"].tap()

        app.buttons["Health Summary"].assertExists()
        app.buttons["Health Summary"].tap()

        app.segmentedControls.buttons["PDF"].assertExists()
        app.segmentedControls.buttons["QR Code"].assertExists()

        // The share link only appears once the summary has been exported, which is a round trip rather
        // than a render.
        app.navigationBars.buttons["Share Link"].assertExists()

        app.segmentedControls.buttons["QR Code"].tap()

        app.navigationBars.buttons["Share Link"].assertExists()
        app.staticTexts["Health Summary QR Code"].assertExists()
        app.staticTexts["One-time Code"].assertExists()
    }
}
