//
//  HomeViewModelTests.swift
//  FlavorFlashTests
//
//  Created by 鍾哲玄 on 2024/1/7.
//

import XCTest
@testable import FlavorFlash

@MainActor
final class HomeViewModelTests: XCTestCase {
	func test_generateRandomFoodCategory() async {
		let mockUserService = MockUserService()
		let mockAuthService = MockAuthService()
		let mockPlaceService = MockPlaceService()

		let viewModel = HomeViewModel(userService: mockUserService, authService: mockAuthService, placeService: mockPlaceService)

		try? await viewModel.initialize()
		
		let loopCount = Int.random(in: 1...100)
		for _ in 0..<loopCount {
			viewModel.randomCategory()
			XCTAssertNotNil(viewModel.category)
		}
	}

	func test_fetchNearbyRestaurants_success() async {
		let mockUserService = MockUserService()
		let mockAuthService = MockAuthService()
		let mockPlaceService = MockPlaceService()

		let viewModel = HomeViewModel(
			userService: mockUserService,
			authService: mockAuthService,
			placeService: mockPlaceService)

		try? await viewModel.initialize()

		viewModel.fetchNearby {
			XCTAssertEqual(viewModel.restaurants.count, Int(viewModel.maxResultCount ?? 20))
		}
	}
}
