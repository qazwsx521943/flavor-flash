//
//  FFUser.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation

struct FFUser: Codable, Hashable, Identifiable {
	let id: String
	let displayName: String
	let email: String?
	let profileImageUrl: String?
	let profileImagePath: String?
	let dateCreated: Date?
	let favoriteRestaurants: [String]? = nil
	let friends: [String]?
	let categoryPreferences: [String]?

	enum CodingKeys: String, CodingKey {
		case id = "user_id"
		case displayName = "display_name"
		case email
		case profileImageUrl = "profile_image_url"
		case profileImagePath = "profile_image_path"
		case dateCreated = "date_created"
		case favoriteRestaurants = "favorite_restaurants"
		case friends
		case categoryPreferences
	}
}

extension FFUser {
	// prevent overriding memberwise initializer
	init(auth: AuthDataResultModel) {
		self.id = auth.uid
		self.email = auth.email
		self.profileImageUrl = auth.photoUrl
		self.profileImagePath = nil
		self.friends = nil
		self.dateCreated = Date()
		self.displayName = "Anonymous"
		self.categoryPreferences = nil
	}

	init(auth: AuthDataResultModel, displayName: String) {
		self.id = auth.uid
		self.email = auth.email
		self.profileImageUrl = auth.photoUrl
		self.profileImagePath = nil
		self.friends = nil
		self.dateCreated = Date()
		self.displayName = displayName
		self.categoryPreferences = nil
	}
}
