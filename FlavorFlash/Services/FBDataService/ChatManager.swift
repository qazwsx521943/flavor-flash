//
//  ChatManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import OSLog

final class ChatManager {
	static let shared = ChatManager()

	private let chatCollection = Firestore.firestore().collection("chats")

	private let groupCollection = Firestore.firestore().collection("groups")

	private init() {}

	// MARK: - Convenient helpers
	private func getMessageCollection(groupId: String) -> CollectionReference {
		chatCollection.document(groupId).collection("messages")
	}

	private var createdDateFieldKey: String {
		FBMessage.CodingKeys.createdDate.rawValue
	}

	// MARK: - Group Collection CRUD

	public func createGroup(with members: [String]) throws {
		let groupId = UUID().uuidString
		do {
			try groupCollection.document(groupId).setData(from: FBGroup(id: groupId, members: members))
		} catch {
			throw FBStoreError.addDocError
		}
	}

	// get the chatrooms that an user belongs to
	public func getGroups(userId: String) async throws -> [FBGroup] {
		let groupSnapshot = try await groupCollection.whereField("members", arrayContains: userId).getDocuments()
		logger.info("\(userId) belongs to \(groupSnapshot.count) chatroom")

		do {
			let groups = try groupSnapshot.documents.map { try $0.data(as: FBGroup.self) }

			return groups
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	public func groupListener(groupId: String, completionHandler: @escaping ([FBMessage], ListenerRegistration?) -> Void) {
		var listener: ListenerRegistration?

		listener = getMessageCollection(groupId: groupId)
			.order(by: createdDateFieldKey)
			.addSnapshotListener { [weak listener] collectionSnapshot, _ in

			guard let collectionSnapshot else { return }

			do {
				let newMessages: [FBMessage] = try collectionSnapshot.documentChanges.compactMap {
					guard $0.type == .added else { return nil }
					return try $0.document.data(as: FBMessage.self)
				}

				// return listener so that when we exit an chat, we can detach the previous chat listener
				completionHandler(newMessages, listener)
			} catch {
				// FIXME: - uncatched
//				throw FBStoreError.fetchError
			}
		}
	}

	public func getGroupMemberId(groupId: String) async throws -> [String] {
		do {
			let group = try await groupCollection.document(groupId).getDocument(as: FBGroup.self)
			return group.members
		} catch {
			throw FBStoreError.fetchError
		}
	}

	// MARK: - Message Collection CRUD
	public func getGroupMessages(groupId: String) async throws -> [FBMessage] {

		let chatSnapshot = try await getMessageCollection(groupId: groupId)
			.order(by: createdDateFieldKey)
			.getDocuments()

		do {
			let messages = try chatSnapshot.documents.map { try $0.data(as: FBMessage.self) }

			return messages
		} catch {
			throw URLError(.unknown)
		}
	}

	public func sendMessage(groupId: String, message: FBMessage) async throws {
		let messagesCollection = getMessageCollection(groupId: groupId)

		do {
			try messagesCollection.addDocument(from: message)
		} catch {
			throw URLError(.badServerResponse)
		}
	}
}

// MARK: - UGC conform
extension ChatManager {
	public func deleteGroup(with blockId: String, from userId: String) async throws {
		let docs = try await groupCollection
			.whereField("members", arrayContainsAny: [blockId, userId])
			.getDocuments()

		logger.debug("\(userId) and the blocked user \(blockId) has \(docs.count) chatrooms")

		do {
			let groups = try docs.documents.map { try $0.data(as: FBGroup.self) }

			let filteredGroup = groups.filter { group in
				group.members.allSatisfy { id in
					id == blockId || id == userId
				}
			}

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

fileprivate let logger = Logger(subsystem: "ios22-jason.FlavorFlash", category: "ChatManager")
