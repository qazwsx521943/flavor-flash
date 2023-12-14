//
//  ChatManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

final class ChatManager {
	static let shared = ChatManager()

	private let chatCollection = Firestore.firestore().collection("chats")

	private let groupCollection = Firestore.firestore().collection("groups")

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

		let chatSnapshot = try await chatCollection
			.document(groupId)
			.collection("messages")
			.order(by: "created_date")
			.getDocuments()

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

		listener = chatCollection
			.document(groupId)
			.collection("messages")
			.order(by: "created_date")
			.addSnapshotListener { [weak listener] collectionSnapshot, _ in

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

	func createNewGroup(with members: [String]) throws {
		let groupId = UUID().uuidString
		do {
			try groupCollection.document(groupId).setData(from: FBGroup(id: groupId, members: members))
		} catch {
			throw FBStoreError.addDocError
		}
	}
}

// MARK: - UGC conform
extension ChatManager {
	public func deleteGroup(with blockId: String, from userId: String) async throws {
		let docs = try await groupCollection
			.whereField("members", arrayContainsAny: [blockId, userId])
			.getDocuments()
		debugPrint("groupdocs: \(docs.documents.count)")

		do {
			let groups = try docs.documents.map { try $0.data(as: FBGroup.self) }
			debugPrint("groups: \(groups)")
			let filteredGroup = groups.filter { group in
				group.members.allSatisfy { id in
					id == blockId || id == userId
				}
			}

			print("filterd Group", filteredGroup.map { $0.id })
			if !filteredGroup.isEmpty {
				for group in filteredGroup {
					try await groupCollection.document(group.id).delete()
				}
			}

		} catch {
			throw URLError(.badServerResponse)
		}

	}
}
