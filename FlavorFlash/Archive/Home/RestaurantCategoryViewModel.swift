//
//  RestaurantCategoryViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import Foundation

final class RestaurantCategoryViewModel: ObservableObject {
	var allCategories = RestaurantCategory.allCases
//	@Published var selectedCategories = Set<String>()
	@Published var selectedCategories = RestaurantCategory.allCases

	func saveCategories() async throws {
		do {
			let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()

			try await UserManager.shared.setRestaurantCategories(
				userId: currentUser.uid,
				categories: Array(selectedCategories).toString)
		} catch {
			throw FBAuthError.userNotLoggedIn
		}
	}
//
//	func addCategory(_ category: RestaurantCategory) {
//		selectedCategories.append(category)
//	}

	func load() async throws {
		try await Task.sleep(nanoseconds: 2_000_000)
		print("sleep over")
		print(selectedCategories.count)
	}
}
