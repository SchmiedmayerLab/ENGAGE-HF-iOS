//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class HeartHealthUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = [
            "--skipOnboarding",
            "--setupTestEnvironment",
            "--testMockDevices",
            "--useFirebaseEmulator",
            "--skipRemoteNotificationRegistration"
        ]
        app.launch()
        
        try await Task.sleep(for: .seconds(2))
        addNotificatinosUIInterruptionMonitor()
        try await Task.sleep(for: .seconds(0.5))
    }
    
    func testSymptomScores() throws {
        let app = XCUIApplication()
        
        app.goTo(tab: "Heart Health")
        app.testEmptySymptomScores()
    }
    
    func testEmptyBodyWeight() throws {
        let app = XCUIApplication()
        
        // Clear out any data present before continuing
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        app.testEmptyVitals(for: "Body Weight", pickerLabel: "Weight")
    }
    
    func testEmptyHeartRate() throws {
        let app = XCUIApplication()
        
        // Clear out any data present before continuing
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        app.testEmptyVitals(for: "Heart Rate", pickerLabel: "HR")
    }
    
    func testEmptyBloodPressure() throws {
        let app = XCUIApplication()
        
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        app.testEmptyVitals(for: "Blood Pressure", pickerLabel: "BP")
    }
    
    func testWithWeightSample() async throws {
        let app = XCUIApplication()
        
        let expectedWeight = Locale.current.measurementSystem == .us ? "92.6" : "42.0"
        let expectedUnit = Locale.current.measurementSystem == .us ? "lb" : "kg"
        
        // Start fresh
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        
        // Trigger a measurement
        app.goTo(tab: "Home")
        await app.triggerMockMeasurement("Weight", expect: ["42 kg"])
        app.goTo(tab: "Heart Health")
        
        // Test to make sure the graph appears
        try await app.testGraphWithSamples(
            id: ("Weight", "Body Weight"),
            expectedQuantity: (expectedWeight, expectedUnit)
        )
        
        // Test to make sure the All Data section has an item in it
        app.scrollToElement(app.staticTexts["Weight Quantity: \(expectedWeight)"])
        app.staticTexts["Empty Weight List"].assertDisappears()
        app.staticTexts["Weight Unit: \(expectedUnit)"].assertExists()
        app.staticTexts["Weight Date: Jun 5, 2024"].assertExists()
        
        // Make sure the empty views return when we delete the data
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        app.testEmptyVitals(for: "Body Weight", pickerLabel: "Weight")
    }
    
    func testWithHeartRateSample() async throws {
        let app = XCUIApplication()

        // Start fresh
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        
        // Trigger a measurement
        app.goTo(tab: "Home")
        await app.triggerMockMeasurement("Blood Pressure", expect: ["103/64 mmHg", "62 BPM"])
        app.goTo(tab: "Heart Health")
        
        // Test to make sure the graph appears
        try await app.testGraphWithSamples(
            id: ("HR", "Heart Rate"),
            expectedQuantity: ("62", "BPM")
        )
        
        // Test to make sure the All Data section has an item in it
        app.scrollToElement(app.staticTexts["HR Quantity: 62"])
        app.staticTexts["Empty HR List"].assertDisappears()
        app.staticTexts["HR Unit: BPM"].assertExists()
        app.staticTexts["HR Date: Jun 5, 2024"].assertExists()
        
        // Make sure the empty views return when we delete the data
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        app.testEmptyVitals(for: "Heart Rate", pickerLabel: "HR")
    }
    
    func testWithBloodPressureSample() async throws {
        let app = XCUIApplication()
        
        // Start fresh
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        
        // Trigger a measurement
        app.goTo(tab: "Home")
        await app.triggerMockMeasurement("Blood Pressure", expect: ["103/64 mmHg", "62 BPM"])
        app.goTo(tab: "Heart Health")
        
        // Test to make sure the graph appears
        try await app.testGraphWithSamples(
            id: ("BP", "Blood Pressure"),
            expectedQuantity: ("103/64", "mmHg")
        )
        
        // Test to make sure the All Data section has an item in it
        app.scrollToElement(app.staticTexts["BP Quantity: 103/64"])
        app.staticTexts["Empty BP List"].assertDisappears()
        app.staticTexts["BP Unit: mmHg"].assertExists()
        app.staticTexts["BP Date: Jun 5, 2024"].assertExists()
        
        // Make sure the empty views return when we delete the data
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        app.testEmptyVitals(for: "Blood Pressure", pickerLabel: "BP")
    }
}


extension XCUIApplication {
    private func getExpectedDateRanges() throws -> [String] {
        let now = Date()
        let calendar = Calendar.current
        
        let weeklyDomainStart = try XCTUnwrap(calendar.date(byAdding: .month, value: -3, to: now))
        let weekRangeStart = try XCTUnwrap(calendar.dateInterval(of: .weekOfYear, for: weeklyDomainStart)?.start)
        let weekRangeEnd = try XCTUnwrap(calendar.dateInterval(of: .weekOfYear, for: now)?.end)
        let adjustedWeekRangeEnd = weekRangeEnd.addingTimeInterval(-1)
        
        let weeklyRange = (weekRangeStart..<adjustedWeekRangeEnd).formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
        
        let monthlyDomainStart = try XCTUnwrap(calendar.date(byAdding: .month, value: -6, to: now))
        let monthRangeStart = try XCTUnwrap(calendar.dateInterval(of: .month, for: monthlyDomainStart)?.start)
        let monthRangeEnd = try XCTUnwrap(calendar.dateInterval(of: .month, for: now)?.end)
        let adjustedMonthRangeEnd = monthRangeEnd.addingTimeInterval(-1)
        
        let monthlyRange = (monthRangeStart..<adjustedMonthRangeEnd).formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
        
        return [weeklyRange, monthlyRange]
    }
    
    
    fileprivate func testGraphWithSamples(
        id: (short: String, full: String),
        expectedQuantity: (value: String, unit: String)
    ) async throws {
        let expectedRanges = try getExpectedDateRanges()
        
        // Verify that each graph appears correctly
        for (resolution, expectedRange) in zip(["Weekly", "Monthly"], expectedRanges) {
            let pickerID = resolution == "Weekly" ? "Daily" : "Weekly"
            
            await testGraph(
                id: id,
                expectedQuantity: expectedQuantity,
                dateInfo: (resolution, expectedRange),
                pickerID: pickerID
            )
        }
    }
    
    
    fileprivate func testGraph(
        id: (short: String, full: String),
        expectedQuantity: (value: String, unit: String),
        dateInfo: (granularity: String, range: String),
        pickerID: String
    ) async {
        // Make sure the vitals are correctly displayed
        goToHeartHealth(segment: id.short, header: id.full)
        
        // Make sure the measurement is displayed in "All Data" section
        scrollToElement(staticTexts["\(id.short) Quantity: \(expectedQuantity.value)"])
        staticTexts["\(id.short) Unit: \(expectedQuantity.unit)"].assertExists()
        staticTexts["\(id.short) Date: Jun 5, 2024"].assertExists()

        // Navigate to weekly data
        let resolutionPicker = buttons["Resolution Picker, \(pickerID)"]
        scrollToElement(resolutionPicker, .swipingDown)
        resolutionPicker.tap()
        buttons[dateInfo.granularity].assertExists()
        buttons[dateInfo.granularity].tap()
        try? await Task.sleep(for: .seconds(1))
        
        // Make sure the vitals graph is present
        XCTAssert(otherElements["Vitals Graph"].waitForExistence(timeout: 2.0))
        
        // The following two assertions would make sure that the value is actually shown as the title of the
        // chart. Unfortunately, the test data is always from Jun 5, 2024 and the tests are run with the current time.
        // Therefore, the values will not actually be part of the chart at all and therefore, these assertions currently
        // fail.
        //
        // XCTAssert(staticTexts["Overall Summary Quantity: \(expectedQuantity.value)"].waitForExistence(timeout: 5.0))
        // XCTAssert(staticTexts["Overall Summary Unit: \(expectedQuantity.unit)"].waitForExistence(timeout: 5.0))
        
        // Make sure the overall average appears correctly
        XCTAssert(staticTexts[dateInfo.range].waitForExistence(timeout: 0.5))
    }
    
    
    func triggerMockMeasurement(_ displayName: String, expect measurements: [String]) async {
        XCTAssert(navigationBars.buttons["More"].exists)
        navigationBars.buttons["More"].tap()
        
        XCTAssert(buttons["Trigger \(displayName) Measurement"].waitForExistence(timeout: 0.5))
        buttons["Trigger \(displayName) Measurement"].tap()
        
        XCTAssert(staticTexts["Measurement Recorded"].waitForExistence(timeout: 2.0))
        for vital in measurements {
            XCTAssert(staticTexts[vital].exists)
        }
        
        XCTAssert(buttons["Discard"].exists)
        XCTAssert(buttons["Save"].exists)

        buttons["Save"].tap()
        try? await Task.sleep(for: .seconds(1))

        XCTAssertFalse(alerts.element.exists)
    }
}


extension XCUIApplication {
    fileprivate func testEmptyVitals(for vitalType: String, pickerLabel: String) {
        XCTAssert(buttons[pickerLabel].waitForExistence(timeout: 0.5))
        buttons[pickerLabel].tap()
                
        XCTAssert(staticTexts["Overall Summary Quantity: No Data"].waitForExistence(timeout: 2))
        XCTAssert(staticTexts["About \(vitalType)"].waitForExistence(timeout: 0.5))
        staticTexts["About \(vitalType)"].swipeUp()
        XCTAssert(staticTexts["\(vitalType) Description"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Empty \(pickerLabel) List"].waitForExistence(timeout: 0.5))
        swipeDown()
    }
    
    fileprivate func testEmptySymptomScores() {
        XCTAssert(buttons["Symptoms"].firstMatch.waitForExistence(timeout: 0.5))
        buttons["Symptoms"].firstMatch.tap()
        
        let symptomTypes = [
            "Overall",
            "Physical Limits",
            "Social Limits",
            "Quality of Life",
            "Symptom Frequency",
            "Dizziness"
        ]
        let symptomLabels = [
            "Overall",
            "Physical",
            "Social",
            "Quality of Life",
            "Specific Symptoms",
            "Dizziness"
        ]
        
        let numTypes = symptomTypes.count
        
        // Iterate over each symptom type and check that each is empty
        for idx in 0..<numTypes {
            let nextIdx = (idx + 1) % numTypes
            
            XCTAssert(buttons["\(symptomTypes[idx]) Score, Symptoms Picker Chevron"].waitForExistence(timeout: 0.5))
            buttons["\(symptomTypes[idx]) Score, Symptoms Picker Chevron"].tap()
            
            XCTAssert(buttons["\(symptomLabels[nextIdx])"].firstMatch.waitForExistence(timeout: 0.5))
            buttons["\(symptomLabels[nextIdx])"].firstMatch.tap()
            
            testEmptyForSpecificType(scoreType: symptomTypes[nextIdx])
        }
    }
    
    private func testEmptyForSpecificType(scoreType: String) {
        staticTexts["Overall Summary Quantity: No Data"].assertExists()
        staticTexts["\(scoreType) Score Description"].assertExists()
        staticTexts["About \(scoreType) Score"].assertExists()
        staticTexts["About \(scoreType) Score"].swipeUp()
        staticTexts["Empty Symptoms List"].assertExists()
        swipeDown()
    }
}
