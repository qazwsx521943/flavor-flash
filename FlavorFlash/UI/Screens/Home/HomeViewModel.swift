//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import MapKit
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var category: RestaurantCategory?

	@Published var userCategories: [RestaurantCategory] = []

	@Published var currentUser: FFUser?

    @Published var currentLocation: CLLocationCoordinate2D?

    @Published var restaurants: [Restaurant] = []

    @Published var selectedRestaurant: Restaurant?

	@Published var inputImage: UIImage?

	@Published var userSavedRestaurants: [Restaurant] = []

	@AppStorage("maxResultCount") var maxResultCount: Double?

	@AppStorage("searchRadius") var searchRadius: Double?

	@AppStorage("rankPreference") var rankPreference: PlaceFetcher.RankPreference?

	init() {
		Task {
			try await loadCurrentUser()
			try await loadUserSavedRestaurants()

			UserManager.shared.listenToChange(userId: currentUser!.id) { [weak self] user in
				self?.currentUser = user
			}
		}
	}

	public func randomCategory() {
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

	private func loadUserSavedRestaurants() async throws {
		guard let savedRestaurantIds = currentUser?.favoriteRestaurants else { return }

		var restaurants: [Restaurant] = []

		try await withThrowingTaskGroup(of: Restaurant.self) { group in
			for id in savedRestaurantIds {
				group.addTask {
					try await PlaceFetcher.shared.fetchPlaceDetailById(id: id)
				}
			}

			for try await restaurant in group {
				restaurants.append(restaurant)
			}

			self.userSavedRestaurants = restaurants
		}
	}
}

extension HomeViewModel {
	// MARK: - VM Firebase CRUD
	func saveFavoriteRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try UserManager.shared.saveUserFavoriteRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func saveLovedRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try UserManager.shared.saveUserLovedRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func saveBlockedRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try UserManager.shared.saveUserBlockedRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}
}
