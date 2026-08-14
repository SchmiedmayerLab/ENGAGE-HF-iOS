//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Tries to navigate to a tab by clicking on a button in the current view with label "id", and verifies the correct arrival by looking for a header with label "header" or "id" if no header given.
    func goTo(tab tabName: String, header: String? = nil) {
        func navigateToTab() {
            buttons[tabName].assertExists("No button found for tab \(tabName)")
            buttons[tabName].tap()
            swipeDown()
        }
        
        navigateToTab()
        
        guard !staticTexts[header ?? tabName].waitForExistence(timeout: 2.0) else {
            return
        }
        
        navigateToTab()
        
        staticTexts[header ?? tabName].assertExists()
    }
    
    func goToHeartHealth(segment: String, header: String) {
        goTo(tab: "Heart Health")
        
        buttons[segment].assertExists("No button found for segment \(segment)")
        buttons[segment].tap()
        
        staticTexts["About \(header)"].swipeDown()
        staticTexts[header].assertExists()
    }
}
