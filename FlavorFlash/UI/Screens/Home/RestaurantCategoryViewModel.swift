//
//  RestaurantCategoryViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import Foundation

final class RestaurantCategoryViewModel: ObservableObject {
	let allCategories = RestaurantCategory.allCases
	@Published var selectedCategories: [RestaurantCategory] = []

	func saveCategories() async throws {
		do {
			let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()

			try await UserManager.shared.setRestaurantCategories(userId: currentUser.uid, categories: selectedCategories.toString)
		} catch {
			throw FBAuthError.userNotLoggedIn
		}
	}

	func addCategory(_ category: RestaurantCategory) {
		selectedCategories.append(category)
	}
}
