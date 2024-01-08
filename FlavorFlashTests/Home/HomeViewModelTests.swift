//
//  HomeViewModelTests.swift
//  FlavorFlashTests
//
//  Created by 鍾哲玄 on 2024/1/7.
//

import XCTest
@testable import FlavorFlash

final class HomeViewModelTests: XCTestCase {

	@MainActor 
	func test_generateRandomFoodCategory() async {
		let mockUserService = MockUserService()
		let mockAuthService = MockAuthService()

		let viewModel = HomeViewModel(userService: mockUserService, authService: mockAuthService)

		try? await viewModel.initialize()
		
		let loopCount = Int.random(in: 1...100)
		for _ in 0..<loopCount {
			viewModel.randomCategory()
			XCTAssertNotNil(viewModel.category)
		}
	}
}
