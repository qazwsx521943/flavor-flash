//
//  MockUserService.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2024/1/8.
//

import Foundation

class MockUserService: UserServiceProtocol {
	let user = FBUser.mockUser()

	func createUser(user: FBUser) async throws {

	}
	
	func getUser(userId: String) async throws -> FBUser {
		return user
	}
	
	func listenToChange(userId: String, completionHandler: @escaping (FBUser) -> Void) {
		completionHandler(user)
	}
	
	func getUserFriends(ids: [String]) async throws -> [FBUser] {
		return []
	}
	
	func updateUserProfileImagePath(userId: String, path: String, url: String) async throws {

	}
	
	func addFriend(userId: String, from currentUser: String) async throws {

	}
	
	func setRestaurantCategories(userId: String, categories: [String]) async throws {

	}
	
	func saveUserFavoriteRestaurant(userId: String, restaurant: Restaurant) throws {

	}
	
	func saveUserLovedRestaurant(userId: String, restaurant: Restaurant) throws {

	}
	
	func saveUserBlockedRestaurant(userId: String, restaurant: Restaurant) throws {

	}
	
	func saveUserFoodPrint(userId: String, foodPrint: FBFoodPrint) async throws {

	}
	
	func blockFriend(blockId: String, from userId: String) async throws {

	}
	
	func deleteFriend(deleteId: String, from userId: String) async throws {

	}
}
