//
//  Group.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation

struct FBGroup: Codable, Identifiable {
	let id: String
	let members: [String]
}
