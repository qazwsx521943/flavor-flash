//
//  FoodPrintViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import Foundation

@MainActor
class FoodPrintViewModel: ObservableObject {
	@Published var posts: [FoodPrint] = []

	@Published var currentUser: FFUser?

	init() {
		Task {
			try await loadCurrentUser()
			try await getPosts()
		}
	}

	func loadCurrentUser() async throws {
		let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()

		guard let authDataResultModel = authUser else { return }
		self.currentUser = try await UserManager.shared.getUser(userId: authDataResultModel.uid)
	}

	func getPosts() async throws {
		guard let friends = currentUser?.friends else { return }
		self.posts = try await FoodPrintManager.shared.getUserPosts(including: friends)
	}
}
