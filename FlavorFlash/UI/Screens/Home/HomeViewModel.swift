//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import MapKit
import SwiftUI
import FirebaseAuth

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var category: RestaurantCategory?

	@Published var userCategories: [RestaurantCategory] = []

	@Published var currentUser: FBUser?

    @Published var currentLocation: CLLocationCoordinate2D?

    @Published var restaurants: [Restaurant] = []

    @Published var selectedRestaurant: Restaurant?

	@Published var inputImage: UIImage?

	@Published var userSavedRestaurants: [Restaurant] = []

	@AppStorage("maxResultCount") var maxResultCount: Double?

	@AppStorage("searchRadius") var searchRadius: Double?

	@AppStorage("rankPreference") var rankPreference: RankPreference?

	private var userService: UserServiceProtocol
	private var authService: AuthServiceProtocol
	private var placeService: PlaceServiceProtocol

	init(
		userService: UserServiceProtocol = UserManager.shared,
		authService: AuthServiceProtocol = AuthenticationManager.shared,
		placeService: PlaceServiceProtocol = PlaceFetcher.shared
	) {
		self.userService = userService
		self.authService = authService
		self.placeService = placeService
//		NotificationCenter.default.addObserver(forName: .AuthStateDidChange, object: nil, queue: nil) { [weak self] _ in
//			try? self?.checkUpdate()
//		}
	}

	public func randomCategory() {
		guard !userCategories.isEmpty else { return }
		category = userCategories.randomElement()!
	}

	public func initialize() async throws {
		try await loadCurrentUser()
		try await loadUserSavedRestaurants()

		userService.listenToChange(userId: currentUser!.id) { [weak self] user in
			self?.currentUser = user
		}
	}

	private func loadCurrentUser() async throws {
		guard let currentUser = try? authService.getAuthenticatedUser()
		else {
			throw FBAuthError.userNotLoggedIn
		}

		let user = try await userService.getUser(userId: currentUser.uid)

		self.currentUser = user
		if let categoryPreferences = user.categoryPreferences {
			self.userCategories = categoryPreferences.compactMap { RestaurantCategory(rawValue: $0) }
		}
	}

	private func loadUserSavedRestaurants() async throws {
		guard let savedRestaurantIds = currentUser?.toEatRestaurantList else { return }

		var restaurants: [Restaurant] = []

		try await withThrowingTaskGroup(of: Restaurant.self) { [weak self] group in
			guard let self else { return }

			for id in savedRestaurantIds {
				group.addTask {
					try await self.placeService.fetchPlaceDetailById(id: id)
				}
			}

			for try await restaurant in group {
				restaurants.append(restaurant)
			}

			self.userSavedRestaurants = restaurants
		}
	}

	public func checkUpdate() throws {
		if Auth.auth().currentUser?.uid != currentUser?.id {
			Task {
				try await loadCurrentUser()
				try await loadUserSavedRestaurants()

				userService.listenToChange(userId: currentUser!.id) { [weak self] user in
					self?.currentUser = user
				}
			}
		} else {
			return
		}
	}

	public func fetchNearby(completionHandler: (() -> ())? = nil) {
		guard
			let categoryTag = category?.rawValue,
			let location = currentLocation
		else { return }
		placeService.fetchNearBy(
			type: [categoryTag],
			location: Location(CLLocation: location),
			maxResultCount: Int(maxResultCount ?? 20),
			rankPreference: rankPreference ?? .distance,
			radius: searchRadius ?? 1000) { [weak self] result in
				switch result {
				case .success(let result):
					self?.restaurants = result.places

				case .failure(let error):
					debugPrint(error.localizedDescription)
				}
			}
	}
}

extension HomeViewModel {
	// MARK: - VM Firebase CRUD
	func saveFavoriteRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try userService.saveUserFavoriteRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func saveLovedRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try userService.saveUserLovedRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func saveBlockedRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try userService.saveUserBlockedRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}
}
