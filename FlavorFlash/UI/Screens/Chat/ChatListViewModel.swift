//
//  ChatroomViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import MessageKit
import Combine

//final class ChatroomViewModel<DI: DataService>: ObservableObject where DI.Item == FFMessage {
@MainActor
final class ChatListViewModel: ObservableObject {
//    @Published var messages: [MessageType] = []

	@Published var groups: [FBGroup]?

	private(set) var user: FFUser?

	init() {
		Task {
			try? await loadUser()
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

	func getGroups() async throws {
		guard let user else { return }

		let groups = try await ChatManager.shared.getGroups(userId: user.userId)
		debugPrint(user.userId)
		debugPrint(groups)
		self.groups = groups
	}

//	func getMessages(groupId: String) async throws -> [MessageType] {
//
//		let messages = try await ChatManager.shared.getGroupMessages(groupId: groupId)
//
//		let mkMessages = messages.map { Message(sender: Sender(senderId: $0.senderId, displayName: $0.senderName), messageId: $0.id, sentDate: $0.createdDate, kind: .text($0.text)) }
//		
//		self.messages = mkMessages
//		return mkMessages
//	}
}
