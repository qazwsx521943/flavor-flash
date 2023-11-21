//
//  ChatroomViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation
import MessageKit
import Combine
import FirebaseFirestore

//final class ChatroomViewModel<DI: DataService>: ObservableObject where DI.Item == FFMessage {
//@MainActor
final class ChatroomViewModel: ObservableObject {
	@Published var messages: [MessageType] = []
	private(set) var groupId: String
	var members: [FFUser]?
	private(set) var listener: ListenerRegistration?

	private(set) var user: FFUser?

	init(groupId: String) {
		self.groupId = groupId
		Task {
			try await loadUser()
			try await loadGroupMember()
//			try await getMessages(groupId: groupId)
			listen()
		}
	}

	func loadGroupMember() async throws {
		var members: [FFUser] = []
		do {
			let ids = try await ChatManager.shared.getGroupMemberId(groupId: groupId)

			for id in ids {
				let member = try await UserManager.shared.getUser(userId: id)
				members.append(member)
			}

			self.members = members
		} catch {
			debugPrint("fetch group error")
		}
	}

	func loadUser() async throws {
		guard
			let userResultModel = try? AuthenticationManager.shared.getAuthenticatedUser()
		else {
			debugPrint("not logged in")
			return
		}

		self.user = try await UserManager.shared.getUser(userId: userResultModel.uid)
	}

	func getMessages(groupId: String) async throws -> [MessageType] {

		let messages = try await ChatManager.shared.getGroupMessages(groupId: groupId)

		let mkMessages = messages.map {
			Message(
				sender: Sender(senderId: $0.senderId, displayName: $0.senderName),
				messageId: $0.id,
				sentDate: $0.createdDate,
				kind: .text($0.text))
		}

		self.messages = mkMessages
		return mkMessages
	}

	func sendMessage(text: String) async throws {
		guard let user else { return }
		
		let message = FBMessage(id: UUID().uuidString, text: text, senderName: user.displayName ?? "Anonymous", senderId: user.userId, createdDate: Date())

		try await ChatManager.shared.sendMessage(groupId: groupId, message: message)
	}

	func listen() {
		ChatManager.shared.groupListener(groupId: groupId) { messages, listener in
			let mkMessages = messages.map {
				Message(
					sender: Sender(senderId: $0.senderId, displayName: $0.senderName),
					messageId: $0.id,
					sentDate: $0.createdDate,
					kind: .text($0.text))
			}
			self.listener = listener
			self.messages.append(contentsOf: mkMessages)
		}
	}

	func removeListener() {
		self.listener?.remove()
	}
}
