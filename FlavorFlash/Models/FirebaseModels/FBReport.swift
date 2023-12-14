//
//  FBReport.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import Foundation

struct FBReport: FBModelType {
	var id: String
	let type: ReportType
	let reason: ReportReason

	enum CodingKeys: CodingKey {
		case id
		case type
		case reason
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.type.rawValue, forKey: .type)
		try container.encode(self.reason.rawValue, forKey: .reason)
	}
}

enum ReportType: String, Codable {
	case foodPrint
	case user
}

enum ReportReason: String, Codable, Hashable, CaseIterable {
	case disgusting
	case trash
	case scam
	case naked
	case other

	var title: String {
		switch self {
		case .disgusting: return "讓我感到噁心"
		case .trash: return "這是垃圾訊息"
		case .naked: return "裸露或性行為"
		case .scam: return "詐騙或詐欺"
		case .other: return "我就是不喜歡"
		}
	}
}
