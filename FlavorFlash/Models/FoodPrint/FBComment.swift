//
//  FBComment.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import Foundation

struct FBComment: FBModelType {
	var id: String
	let userId: String
	let comment: String
	let createdDate: Date

	var relativeDateFormatter: RelativeDateTimeFormatter {
		let formatter = RelativeDateTimeFormatter()
		formatter.dateTimeStyle = .numeric
		formatter.unitsStyle = .short
		formatter.locale = Locale(identifier: "zh-TW")
		return formatter
	}

	var getRelativeTimeString: String {
		relativeDateFormatter.localizedString(for: createdDate, relativeTo: .now)
	}
}
