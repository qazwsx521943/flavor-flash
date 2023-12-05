//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import MapKit

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var category: RestaurantCategory?

	@Published var userCategories: [RestaurantCategory] = []

	@Published var currentUser: FFUser?

    @Published var currentLocation: CLLocationCoordinate2D?

    @Published var restaurants: [Restaurant] = []

    @Published var selectedRestaurant: Restaurant?

	init() {
		Task {
			try await loadCurrentUser()
		}
	}

    func setRestaurants(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
    }

	func randomCategory() {
		print(userCategories)
		guard !userCategories.isEmpty else { return }
		category = userCategories.randomElement()!
	}

	private func loadCurrentUser() async throws {
		guard let currentUser = try? AuthenticationManager.shared.getAuthenticatedUser() 
		else {
			throw FBAuthError.userNotLoggedIn
		}

		let user = try await UserManager.shared.getUser(userId: currentUser.uid)
		debugPrint("home get user: \(user)")
		await MainActor.run {
			self.currentUser = user
			if let categoryPreferences = user.categoryPreferences {
				self.userCategories = categoryPreferences.compactMap { RestaurantCategory(rawValue: $0) }
			}
		}
	}

	func saveFavoriteRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try UserManager.shared.saveUserFavoriteRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}
}
