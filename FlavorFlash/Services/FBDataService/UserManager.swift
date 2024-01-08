//
//  UserManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import OSLog

protocol UserServiceProtocol {
	func createUser(user: FBUser) async throws
	func getUser(userId: String) async throws -> FBUser
	func listenToChange(userId: String, completionHandler: @escaping (FBUser) -> Void)
	func getUserFriends(ids: [String]) async throws -> [FBUser]
	func updateUserProfileImagePath(userId: String, path: String, url: String) async throws
	func addFriend(userId: String, from currentUser: String) async throws
	func setRestaurantCategories(userId: String, categories: [String]) async throws
	func saveUserFavoriteRestaurant(userId: String, restaurant: Restaurant) throws
	func saveUserLovedRestaurant(userId: String, restaurant: Restaurant) throws
	func saveUserBlockedRestaurant(userId: String, restaurant: Restaurant) throws
	func saveUserFoodPrint(userId: String, foodPrint: FBFoodPrint) async throws
	func blockFriend(blockId: String, from userId: String) async throws
	func deleteFriend(deleteId: String, from userId: String) async throws
}

enum FBStoreError: Error {
	case noSuchInputField
	case fetchError
	case addDocError
}

final class UserManager: UserServiceProtocol {

	static let shared = UserManager()

	// MARK: - Properties
	private let userCollection = Firestore.firestore().collection("users")

	private let foodPrintCollection = Firestore.firestore().collection("foodprints")

	private var friendFieldKey: String {
		return FBUser.CodingKeys.friends.rawValue
	}

	private var toEatRestaurantListFieldKey: String {
		return FBUser.CodingKeys.toEatRestaurantList.rawValue
	}

	private init() { }

	// MARK: - User Collection CRUD
	private func userDocument(userId: String) -> DocumentReference {
		userCollection.document(userId)
	}

	public func createUser(user: FBUser) async throws {
		logger.notice("create User: \(user.displayName)")

		try userDocument(userId: user.id).setData(
			from: user,
			merge: false)
	}

	public func getUser(userId: String) async throws -> FBUser {
		logger.debug("get UserId: \(userId)")

		do {
			return try await userDocument(userId: userId).getDocument(as: FBUser.self)
		} catch {
			logger.error("\(FBStoreError.fetchError)")
			throw(FBStoreError.fetchError)
		}
	}

	public func listenToChange(userId: String, completionHandler: @escaping (FBUser) -> Void) {
		userDocument(userId: userId).addSnapshotListener { documentSnapshot, _ in
			guard let document = documentSnapshot else { return }
			guard let user = try? document.data(as: FBUser.self) else { return }

			completionHandler(user)
		}
	}

	public func getUserFriends(ids: [String]) async throws -> [FBUser] {
		var users: [FBUser] = []
		users.reserveCapacity(ids.count)

		return try await withThrowingTaskGroup(of: FBUser?.self) { group in

			for id in ids {
				group.addTask {
					try? await self.getUser(userId: id)
				}
			}

			for try await user in group {
				if let user {
					users.append(user)
				}
			}

			return users
		}
	}
}


// MARK: - User Document CRUD
extension UserManager {
	public func updateUserProfileImagePath(userId: String, path: String, url: String) async throws {
		let docData: [String: Any] = [
			FBUser.CodingKeys.profileImagePath.rawValue: path,
			FBUser.CodingKeys.profileImageUrl.rawValue: url
		]

		try await userDocument(userId: userId).updateData(docData)
	}

	public func addFriend(userId: String, from currentUser: String) async throws {
		logger.notice("\(currentUser) wants to add \(userId) as friend!")

		let currentUserDocData = [friendFieldKey: FieldValue.arrayUnion([currentUser])]
		let addUserDocData = [friendFieldKey: FieldValue.arrayUnion([userId])]

		try await userDocument(userId: userId).updateData(currentUserDocData)
		try await userDocument(userId: currentUser).updateData(addUserDocData)
	}

	public func setRestaurantCategories(userId: String, categories: [String]) async throws {
		let docData: [String: Any] = [
			FBUser.CodingKeys.categoryPreferences.rawValue: categories
		]

		try await userDocument(userId: userId).setData(docData, merge: true)
	}

	public func saveUserFavoriteRestaurant(userId: String, restaurant: Restaurant) throws {
		logger.notice("userId \(userId) add \(restaurant.name) to loved!")

		userDocument(userId: userId).updateData([
			toEatRestaurantListFieldKey: FieldValue.arrayUnion([restaurant.id])
		])
	}

	public func saveUserLovedRestaurant(userId: String, restaurant: Restaurant) throws {
		logger.notice("userId \(userId) add \(restaurant.name) to loved!")

		userDocument(userId: userId).updateData([
			FBUser.CodingKeys.lovedRestaurants.rawValue: FieldValue.arrayUnion([restaurant.id])
		])
		userDocument(userId: userId).updateData([toEatRestaurantListFieldKey: FieldValue.arrayRemove([restaurant.id])])
	}

	public func saveUserBlockedRestaurant(userId: String, restaurant: Restaurant) throws {
		logger.notice("userId \(userId) blocked \(restaurant.name)")

		userDocument(userId: userId).updateData([
			FBUser.CodingKeys.blockedRestaurants.rawValue: FieldValue.arrayUnion([restaurant.id])
		])
		userDocument(userId: userId).updateData([toEatRestaurantListFieldKey: FieldValue.arrayRemove([restaurant.id])])
	}

	// FIXME: - Should be in foodPrint manager
	func saveUserFoodPrint(userId: String, foodPrint: FBFoodPrint) async throws {

		try foodPrintCollection.document(foodPrint.id).setData(from: foodPrint, merge: true)
	}
}

// MARK: - UGC conform
extension UserManager {
	public func blockFriend(blockId: String, from userId: String) async throws {
		try await deleteFriend(deleteId: blockId, from: userId)

		try await userDocument(userId: userId).updateData([
			FBUser.CodingKeys.blockedList.rawValue: FieldValue.arrayUnion([blockId])
		])
	}

	public func deleteFriend(deleteId: String, from userId: String) async throws {
		try await userDocument(userId: userId).updateData([friendFieldKey: FieldValue.arrayRemove([deleteId])])
		try await userDocument(userId: deleteId).updateData([friendFieldKey: FieldValue.arrayRemove([userId])])
	}
}

fileprivate let logger = Logger(subsystem: "ios22-jason.FlavorFlash", category: "UserManager")
