//
//  Group.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation

struct ChatRoom: Identifiable {
	let id: String
	let name: String
	let members: [FBUser]

	init(fbGroup: FBGroup, name: String, members: [FBUser]) {
		self.id = fbGroup.id
		self.name = name
		self.members = members
	}

	func getGroupImage(exclude id: String) -> String {
		members
			.filter { $0.id != id }
			.compactMap { $0.profileImageUrl }
			.first ?? ""
	}
}
