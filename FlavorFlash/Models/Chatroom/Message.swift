//
//  Message.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import MessageKit
import Foundation

struct Message: MessageType {
    var sender: MessageKit.SenderType

    var messageId: String

    var sentDate: Date

    var kind: MessageKit.MessageKind
}

struct FBMessage: Codable {
	let id: String

	let text: String

	let senderName: String

	let senderId: String

	let createdDate: Date

	enum CodingKeys: String, CodingKey {
		case id
		case text
		case senderName = "sender_name"
		case senderId = "sender_id"
		case createdDate = "created_date"
	}
}
