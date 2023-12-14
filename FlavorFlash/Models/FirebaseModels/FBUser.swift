//
//  FFUser.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation

// Firestore User document custom struct
struct FBUser: FBModelType, Hashable {
	var id: String
	let displayName: String
	let email: String?
	let profileImageUrl: String?
	let profileImagePath: String?
	let dateCreated: Date?
	let favoriteRestaurants: [String]?
	let lovedRestaurants: [String]?
	let blockedRestaurants: [String]?
	let friends: [String]?
	let blockedList: [String]?
	let categoryPreferences: [String]?

	enum CodingKeys: String, CodingKey {
		case id = "user_id"
		case displayName = "display_name"
		case email
		case profileImageUrl = "profile_image_url"
		case profileImagePath = "profile_image_path"
		case dateCreated = "date_created"
		case favoriteRestaurants = "favorite_restaurants"
		case lovedRestaurants = "loved_restaurants"
		case blockedRestaurants = "blocked_restaurants"
		case friends
		case blockedList = "blocked_list"
		case categoryPreferences
	}
}

extension FBUser {
	// prevent overriding memberwise initializer
	init(auth: AuthDataResultModel) {
		self.id = auth.uid
		self.email = auth.email
		self.profileImageUrl = auth.photoUrl
		self.profileImagePath = nil
		self.favoriteRestaurants = nil
		self.lovedRestaurants = nil
		self.blockedRestaurants = nil
		self.friends = nil
		self.dateCreated = Date()
		self.displayName = "Anonymous"
		self.blockedList = nil
		self.categoryPreferences = nil
	}

	init(auth: AuthDataResultModel, displayName: String) {
		self.id = auth.uid
		self.email = auth.email
		self.profileImageUrl = auth.photoUrl
		self.profileImagePath = nil
		self.favoriteRestaurants = nil
		self.lovedRestaurants = nil
		self.blockedRestaurants = nil
		self.friends = nil
		self.dateCreated = Date()
		self.displayName = displayName
		self.blockedList = nil
		self.categoryPreferences = nil
	}
}

extension FBUser {
	static func mockUser() -> Self {
		FBUser(
			id: "1",
			displayName: "mock",
			email: "qqqq@mock.com",
			profileImageUrl: "https://picsum.photos/200",
			profileImagePath: "https://picsum.photos/200",
			dateCreated: .now,
			favoriteRestaurants: nil,
			lovedRestaurants: nil,
			blockedRestaurants: nil,
			friends: nil,
			blockedList: nil,
			categoryPreferences: nil)
	}
}
