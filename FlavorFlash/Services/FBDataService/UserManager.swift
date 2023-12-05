//
//  UserManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FBStoreError: Error {
	case noSuchInputField
	case fetchError
	case addDocError
}

final class UserManager {

	static let shared = UserManager()

	private let userCollection = Firestore.firestore().collection("users")

	private let foodPrintCollection = Firestore.firestore().collection("foodprints")

//	private let encoder: Firestore.Encoder = {
//		let encoder = Firestore.Encoder()
//		encoder.keyEncodingStrategy = .convertToSnakeCase
//		return encoder
//	}()
//
//	private let decoder: Firestore.Decoder = {
//		let decoder = Firestore.Decoder()
//		decoder.keyDecodingStrategy = .convertFromSnakeCase
//		return decoder
//	}()

	private func userDocument(userId: String) -> DocumentReference {
		userCollection.document(userId)
	}

	private init() { }

	// MARK: - CRUD
	func createNewUser(user: FFUser) async throws {
		debugPrint("creating new user: \(user)")
		try userDocument(userId: user.id).setData(
			from: user,
			merge: false)
	}

	func getUser(userId: String) async throws -> FFUser {
		do {
			return try await userDocument(userId: userId).getDocument(as: FFUser.self)
		} catch {
			throw(FBStoreError.fetchError)
		}
	}

	func setRestaurantCategories(userId: String, categories: [String]) async throws {
		let docData: [String: Any] = ["categoryPreferences": categories]
		try await userDocument(userId: userId).setData(docData, merge: true)
	}

	// updateDate vs. setData (be careful using setData)
	func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
		let data: [String: Any] = [
			FFUser.CodingKeys.profileImagePath.rawValue: path,
			FFUser.CodingKeys.profileImageUrl.rawValue: url,
		]

		try await userDocument(userId: userId).updateData(data)
	}

	func saveUserFavoriteRestaurant(userId: String, restaurant: Restaurant) throws {
		debugPrint("userId: \(userId), restaurant: \(restaurant)")
//		userDocument(userId: userId).setData(["favorite_restaurants": restaurant.id], merge: true)
		userDocument(userId: userId).updateData(["favorite_restaurants": FieldValue.arrayUnion([restaurant.id])])
	}

	func saveUserFoodPrint(userId: String, foodPrint: FoodPrint) async throws {
		debugPrint("saved foodprint: \(foodPrint)")
		try foodPrintCollection.document(foodPrint.id).setData(from: foodPrint, merge: true)
	}

	func addFriend(userId: String, from currentUser: String) async throws {
		debugPrint("add \(userId) to friend")
		try await userDocument(userId: userId).updateData(["friends": FieldValue.arrayUnion([currentUser])])
		try await userDocument(userId: currentUser).updateData(["friends": FieldValue.arrayUnion([userId])])
	}

	func getUserFriends(ids: [String]) async throws -> [FFUser] {
		var users: [FFUser] = []
		users.reserveCapacity(ids.count)

		return try await withThrowingTaskGroup(of: FFUser?.self) { group in

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
