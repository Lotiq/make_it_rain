//
//  Rain_It_UITests.swift
//  Rain It UITests
//
//  Created by Tsimafei Lobiak on 8/16/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import XCTest

class Rain_It_UITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        
        setupSnapshot(app)
        app.launch()
        //loadAppData()
        //assert(app.wait(for: .runningForeground, timeout: 10))

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let app = XCUIApplication()
        snapshot("entry_view")
        // Get the collection view
        let collectionViewsQuery = app.collectionViews
        let element = collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element

        // Swipe collection view
        element.swipeLeft()
        element.swipeLeft()

        // Get text field
        // app.otherElements.containing(.navigationBar, identifier:"Rain_It.SelectionView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .textField).element.tap()

        snapshot("pounds_uneditied")
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        
        for _ in 0..<4 {
            textField.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        
        // Enter 2019
        app.keys["2"].tap()
        app.keys["0"].tap()
        app.keys["1"].tap()
        app.keys["9"].tap()
        
        snapshot("pounds_edited")
        // Tap outside
        app.otherElements.containing(.navigationBar, identifier:"Rain_It.SelectionView").element(boundBy: 0).tap()
        
        // Tap on the menu button
        app.navigationBars["Rain_It.SelectionView"].children(matching: .button).element(boundBy: 0).tap()
        snapshot("menu_selection")
        
        // Tap on my currencies button
        app.buttons["My Currencies"].tap()

        // Tap on bacon text
        sleep(1)
//        snapshot("my_currencies_view")
//        app.tables.element.cells.element(boundBy: 0).staticTexts["bacon"].tap()
//        snapshot("bacon_currency_editing")
//        // Go back to my currencies menu
//        let cancelButton = app.navigationBars["Rain_It.NewCurrencyView"].buttons["Cancel"]
//        cancelButton.tap()

        // Open fresh
        app.buttons["+"].tap()
        snapshot("new_currency")
        
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
