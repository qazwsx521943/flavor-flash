//
//  FFUser.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation

struct FFUser: Codable {
	let userId: String
	let displayName: String?
	let email: String?
	let photoUrl: String?
	let dateCreated: Date?

	enum CodingKeys: String, CodingKey {
		case userId = "user_id"
		case displayName = "display_name"
		case email
		case photoUrl = "photo_url"
		case dateCreated = "date_created"
	}
}

extension FFUser {
	// prevent overriding memberwise initializer
	init(auth: AuthDataResultModel) {
		self.userId = auth.uid
		self.email = auth.email
		self.photoUrl = auth.photoUrl
		self.dateCreated = Date()
		self.displayName = "Anonymous"
	}

	init(auth: AuthDataResultModel, displayName: String) {
		self.userId = auth.uid
		self.email = auth.email
		self.photoUrl = auth.photoUrl
		self.dateCreated = Date()
		self.displayName = displayName
	}
}
