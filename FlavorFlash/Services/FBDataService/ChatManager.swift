//
//  ChatManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ChatManager {
	static let shared = ChatManager()

	private let chatCollection = Firestore.firestore().collection("chats")

	private let groupCollection = Firestore.firestore().collection("groups")

	private func groupDocument() {

	}

	private init() {}

	func getGroups(userId: String) async throws -> [FBGroup] {
		debugPrint("userID: \(userId)")
		let groupSnapshot = try await groupCollection.whereField("members", arrayContains: userId).getDocuments()
		debugPrint(groupSnapshot.documents.count)
		do {
			let groups = try groupSnapshot.documents.map { try $0.data(as: FBGroup.self) }

			return groups
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func getGroupMessages(groupId: String) async throws -> [FBMessage] {

		let chatSnapshot = try await chatCollection.document(groupId).collection("messages").order(by: "created_date").getDocuments()

		debugPrint("\(groupId) schatSnapshot count: \(chatSnapshot.documents.count)")
		do {
			let messages = try chatSnapshot.documents.map { try $0.data(as: FBMessage.self) }
			debugPrint("messages: \(messages)")
			return messages
		} catch {
			throw URLError(.unknown)
		}
	}

	func sendMessage(groupId: String, message: FBMessage) async throws {
		let messagesCollection = chatCollection.document(groupId).collection("messages")

		do {
			try messagesCollection.addDocument(
				from: message)
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func groupListener(groupId: String, completionHandler: @escaping ([FBMessage], ListenerRegistration?) -> Void) {
		var listener: ListenerRegistration?

		listener = chatCollection.document(groupId).collection("messages").order(by: "created_date").addSnapshotListener { [weak listener] collectionSnapshot, error in

			guard let collectionSnapshot else { return }

			do {
				let newMessages: [FBMessage] = try collectionSnapshot.documentChanges.compactMap {
					guard $0.type == .added else { return nil }
					return try $0.document.data(as: FBMessage.self)
				}

				completionHandler(newMessages, listener)
			} catch {
				print("groupListener error")
			}
		}
	}

	func getGroupMemberId(groupId: String) async throws -> [String] {
		do {
			let group = try await groupCollection.document(groupId).getDocument(as: FBGroup.self)
			return group.members
		} catch {
			debugPrint("chat manager fetch groupid error")
			throw FBStoreError.fetchError
		}
	}
}
