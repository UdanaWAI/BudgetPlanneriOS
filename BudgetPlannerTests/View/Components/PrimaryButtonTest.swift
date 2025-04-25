import XCTest
import SwiftUI
@testable import BudgetPlanner

class PrimaryButtonTests: XCTestCase {
    var actionCalled: Bool!
    
    override func setUp() {
        super.setUp()

        actionCalled = false
    }

    override func tearDown() {
        actionCalled = nil
        super.tearDown()
    }

    func testPrimaryButtonAction() {

        let button = PrimaryButton(title: "Test Button") {
            self.actionCalled = true
        }

        button.action()

        XCTAssertTrue(actionCalled, "The action closure should be called when the button is pressed.")
    }
}
