//
//  ProfileScreenUITests.swift
//  FlavorFlashUITests
//
//  Created by 鍾哲玄 on 2024/1/7.
//

import XCTest

final class ProfileScreenUITests: XCTestCase {

	private var app: XCUIApplication!

	override func setUp() {
		continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments = ["-ui-testing"]
		app.launchEnvironment = ["-networking-success": "1"]

		app.launch()
	}

	override func tearDown() {
		app = nil
	}

	func testDummy() {
		XCTFail()
	}
}
