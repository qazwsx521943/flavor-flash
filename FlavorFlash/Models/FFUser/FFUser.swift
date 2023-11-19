//
//  FFUser.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation

struct FFUser: Codable {
	let userId: String
	let email: String?
	let photoUrl: String?
	let dateCreated: Date?
}

extension FFUser {
	// prevent overriding memberwise initializer
	init(auth: AuthDataResultModel) {
		self.userId = auth.uid
		self.email = auth.email
		self.photoUrl = auth.photoUrl
		self.dateCreated = Date()
	}
}
