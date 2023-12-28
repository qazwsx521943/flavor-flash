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
		case .disgusting: return "Disgusting"
		case .trash: return "Spam"
		case .naked: return "Naked or Violent"
		case .scam: return "Fraud"
		case .other: return "Just don't like it"
		}
	}
}
