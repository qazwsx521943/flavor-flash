//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import MapKit


final class RestaurantViewModel: ObservableObject {
    var category: String
	@Published var currentUser: FFUser?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var restaurants: [Restaurant] = []
    @Published var selectedRestaurant: Restaurant? {
        didSet {
            self.currentLocation = selectedRestaurant?.coordinate
        }
    }

	init(searchCategory: String) {
		self.category = searchCategory
		Task {
			try await loadCurrentUser()
		}
	}

    func setRestaurants(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
    }

	private func loadCurrentUser() async throws {
		guard let currentUser = try? AuthenticationManager.shared.getAuthenticatedUser() else { throw FBAuthError.userNotLoggedIn }

		let user = try await UserManager.shared.getUser(userId: currentUser.uid)

		await MainActor.run {
			self.currentUser = user
		}
	}

	func saveFavoriteRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try UserManager.shared.saveUserFavoriteRestaurant(userId: currentUser.userId, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}
}
