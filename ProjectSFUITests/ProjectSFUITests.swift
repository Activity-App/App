//
//  ProjectSFUITests.swift
//  ProjectSFUITests
//
//  Created by Roman Esin on 15.07.2020.
//

import XCTest

class ProjectSFUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation -
        // required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUsualWorkflow() throws {
        // UI tests must launch the application that they test.

        // Grand Health Data Access
        let app = XCUIApplication()
        app.launchArguments += ["ui-testing"]
        app.launch()

        app.buttons["Continue"].tap()

        app.buttons["Continue"].tap()

        UIPasteboard.general.string = "My name"
        let field = app.textFields["Name"]
        field.tap()
        field.typeText("My Real Name")
        app.buttons["Return"].tap()
        app.buttons["Continue"].tap()

        // This is just to make sure that the authorization screen pops up

        // This actually resets authorization and presents auth screen
        app.resetAuthorizationStatus(for: .health)
        // and this presents the auth screen too.
        app.buttons["Grant Health Data Access"].tap()
        // Here we wait for it to pop up
        sleep(7)

        app.tables.staticTexts["Turn All Categories On"].tap()
        app.navigationBars["Health Access"].buttons["Allow"].tap()

        // Relaunch the app
        app.terminate()
        app.launchArguments.removeAll()
        app.launch()

        let tabBar = app.tabBars["Tab Bar"]

        // Go through the app's tabs
        let competitions = tabBar.buttons["star.fill"]
        let friends = tabBar.buttons["person.3.fill"]
        let profile = tabBar.buttons["person.crop.circle"]

        competitions.tap()

        app.tables.buttons["1st\n5 points\n1 day, 3 hr \nCompetition1"].tap()
        app.navigationBars.buttons["Competitions"].tap()
        app.tables.buttons["1st\n5 points\n11 mths, 12 days \nCompetition2"].tap()
        app.navigationBars.buttons["Competitions"].tap()


//        starFillButton.tap()
//
//        let tablesQuery = app.tables
//        let button = tablesQuery.buttons["1st\n5 points\n1 day, 3 hrs \nCompetition1"]
//        button.tap()
//
//        let competitionsNavigationBar = app.navigationBars["Competitions"]
//        competitionsNavigationBar.buttons["Competitions"].tap()
//        tablesQuery.buttons["1st\n5 points\n11 mths, 12 days \nCompetition2"].tap()
//
//        let ttgc7swiftuip101d24f3de028destinationhostingNavigationBar = app.navigationBars["_TtGC7SwiftUIP10$1d24f3de028DestinationHosting"]
//        let competitionsButton = ttgc7swiftuip101d24f3de028destinationhostingNavigationBar.buttons["Competitions"]
//        competitionsButton.tap()
//        tablesQuery.buttons["1st\n5 points\n3 mths, 22 days \nCompetition3"].tap()
//        competitionsButton.tap()
//        person3FillButton.tap()
//        tablesQuery.buttons["Friend1\nMove: 10/300\nExercise: 1/30\nStand: 4/12"].tap()
//        app.navigationBars["Friend1"].buttons["Friends"].tap()
//        tablesQuery.buttons["Friend2\nMove: 340/300\nExercise: 28/30\nStand: 6/12"].tap()
//        button.tap()
//        ttgc7swiftuip101d24f3de028destinationhostingNavigationBar.buttons["Friend2"].tap()
//        app.navigationBars["Friend2"].buttons["Friends"].tap()
//        starFillButton.tap()
//        competitionsNavigationBar.buttons["plus"].tap()
//
//        let segmentedControlsQuery = app.segmentedControls
//        segmentedControlsQuery.buttons["7 Days"].tap()
//        segmentedControlsQuery.buttons["1 Month"].tap()
//        segmentedControlsQuery.buttons["Custom"].tap()
//
//        let walkingRunningDistanceSwitch = app.switches["Walking/Running Distance"]
//        walkingRunningDistanceSwitch.tap()
//
//        let app2 = app
//        app2.switches["Steps"].tap()
//        walkingRunningDistanceSwitch.tap()
//        walkingRunningDistanceSwitch.tap()
//        app2.buttons["Start the competition"].tap()

    }
}
