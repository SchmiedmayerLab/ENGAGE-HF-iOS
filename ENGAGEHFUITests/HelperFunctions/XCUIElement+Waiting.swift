//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2026 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension TimeInterval {
    /// How long a view may take to settle before a test gives up on it.
    ///
    /// The continuous integration machine runs the suite alongside the Firebase emulators, so a view that
    /// appears instantly on a development machine regularly needs seconds there.
    static let uiTestTimeout: TimeInterval = 10
}


extension XCUIElement {
    /// Asserts that the element is present, waiting for the view to render it first.
    ///
    /// Prefer this over `XCTAssert(element.exists)`, which fails whenever the assertion wins the race
    /// against the view it describes.
    func assertExists(
        timeout: TimeInterval = .uiTestTimeout,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            message.isEmpty ? "\(self) never appeared." : message,
            file: file,
            line: line
        )
    }

    /// Asserts that the element goes away, waiting for the change that the preceding interaction started.
    ///
    /// Prefer this over sleeping for a fixed duration and then reading `exists`: the wait ends as soon as
    /// the element is gone, and it tolerates a round trip that runs long.
    func assertDisappears(
        timeout: TimeInterval = .uiTestTimeout,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            waitForNonExistence(timeout: timeout),
            message.isEmpty ? "\(self) never went away." : message,
            file: file,
            line: line
        )
    }
}


extension XCUIApplication {
    enum ScrollDirection {
        /// Reveals content below the fold.
        case swipingUp
        /// Reveals content above the fold.
        case swipingDown
    }


    /// Scrolls until the element is on screen and asserts that it arrives there.
    ///
    /// A list only renders the rows around the viewport, so an element below the fold does not exist to be
    /// waited for. Swiping a fixed number of times lands somewhere that depends on the row heights of the
    /// moment, which is why waiting longer never rescues it; this scrolls until the element is actually
    /// there instead.
    func scrollToElement(
        _ element: XCUIElement,
        _ direction: ScrollDirection = .swipingUp,
        maxScrolls: Int = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var remainingScrolls = maxScrolls
        while remainingScrolls > 0 && !element.isHittable {
            switch direction {
            case .swipingUp:
                swipeUp()
            case .swipingDown:
                swipeDown()
            }
            remainingScrolls -= 1
        }

        XCTAssertTrue(element.isHittable, "\(element) never scrolled into view.", file: file, line: line)
    }
}
