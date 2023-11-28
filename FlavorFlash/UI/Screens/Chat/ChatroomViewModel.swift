//
//  ChatroomViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation
import Combine
import FirebaseFirestore
import ExyteChat
//final class ChatroomViewModel<DI: DataService>: ObservableObject where DI.Item == FFMessage {
//@MainActor
final class ChatroomViewModel: ObservableObject {
	@Published var messages: [ExyteChat.Message] = []

	private(set) var groupId: String

	var members: [FFUser]?

	private(set) var listener: ListenerRegistration?

	private(set) var user: FFUser?

	var chatroomTitle: String {
		guard 
			let members,
			let user
		else { return "沒有成員" }
		return members.filter { $0.id != user.id }.map { $0.displayName }.joined(separator: ",")
	}

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

	func getMessages(groupId: String) async throws -> [ExyteChat.Message] {

		let messages = try await ChatManager.shared.getGroupMessages(groupId: groupId)
		guard let currentUser = user else { return [] }
		let mkMessages = messages.map {
			ExyteChat.Message(
				id: $0.id,
				user: User(id: $0.senderId, name: $0.senderName, avatarURL: nil, isCurrentUser: currentUser.id == $0.senderId), createdAt: $0.createdDate, text: $0.text)
		}

		self.messages = mkMessages
		return mkMessages
	}

	func sendMessage(message: DraftMessage) {
		guard let user else { return }

		if
			let firstMedia = message.medias.first,
			firstMedia.type == .image
		{
			Task {
				guard let imageData = await firstMedia.getData() else { return }
				let (imagePath, _) = try await StorageManager.shared.saveImage(userId: user.id, data: imageData)
				let imagePathUrl = try await StorageManager.shared.getUrlForImage(path: imagePath)
				let message = FBMessage(id: UUID().uuidString, text: message.text, senderName: user.displayName, senderId: user.id, createdDate: Date(), medias: [imagePathUrl.absoluteString])

				try await ChatManager.shared.sendMessage(groupId: groupId, message: message)
			}
		} else {
			let text = message.text
			Task {
				let message = FBMessage(id: UUID().uuidString, text: text, senderName: user.displayName ?? "Anonymous", senderId: user.id, createdDate: Date(), medias: nil)

				try await ChatManager.shared.sendMessage(groupId: groupId, message: message)
			}
		}
	}

	func listen() {
		guard let currentUser = user else { return }
		ChatManager.shared.groupListener(groupId: groupId) { messages, listener in
			let mkMessages = messages.map {

				var attachment: [Attachment] = []
				if
					let medias = $0.medias,
					let mediaUrl = medias.first
				{
					attachment.append(Attachment(id: mediaUrl, url: URL(string: mediaUrl)!, type: .image))
				}
				return ExyteChat.Message(
					id: $0.id,
					user: User(id: $0.senderId, name: $0.senderName, avatarURL: nil, isCurrentUser: currentUser.id == $0.senderId), createdAt: $0.createdDate, text: $0.text, attachments: attachment)
			}
			self.listener = listener
			self.messages.append(contentsOf: mkMessages)
		}
	}

	func removeListener() {
		self.listener?.remove()
	}
}

