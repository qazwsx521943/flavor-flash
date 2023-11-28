//
//  ChatroomViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {

	@Published var groups: [FBGroup]?

	private(set) var user: FFUser?

	@Published var searchUserText: String = ""

	@Published var searchedResult: [FFUser] = []

	private var cancellables = Set<AnyCancellable>()

	init() {
		Task {
			try? await loadUser()
			try? await getGroups()
		}

		addSubscriber()
	}

	func addSubscriber() {
		$searchUserText
			.debounce(for: 0.3, scheduler: DispatchQueue.main)
			.sink { [weak self] searchText in
				Task {
					try await self?.filterFriend(by: searchText)
				}
			}
			.store(in: &cancellables)
	}

	func loadUser() async throws {
		guard
			let userResultModel = try? AuthenticationManager.shared.getAuthenticatedUser()
		else {
			debugPrint("not logged in")
			return
		}
		debugPrint("chatlist loaded user: \(userResultModel.uid)")
		self.user = try await UserManager.shared.getUser(userId: userResultModel.uid)
	}

	func getGroups() async throws {
		guard let user else { return }

		let groups = try await ChatManager.shared.getGroups(userId: user.id)
		debugPrint(user.id)
		debugPrint(groups)
		self.groups = groups
	}

	func filterFriend(by name: String) async throws {
		try await loadUser()

		guard let ids = user?.friends else { return }

		let friends = try await UserManager.shared.getUserFriends(ids: ids)

		searchedResult = friends.filter { $0.displayName.starts(with: name) }
	}

	func createNewGroup(with id: String) {
		guard let currentUserId = user?.id else { return }
		do {
			try ChatManager.shared.createNewGroup(with: [currentUserId, id])
		} catch {
			debugPrint("error creating new Group")
		}
	}
}
