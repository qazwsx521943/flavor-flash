//
//  FoodPrintViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import SwiftUI
import Combine

@MainActor
class FoodPrintViewModel<DI: FBDataService>: ObservableObject where DI.Item == FoodPrint {
	@Published var posts: [FoodPrint] = []

	@Published var currentUser: FFUser?

	@Published var friends: [FFUser] = []

	private let dataService: DI
	private var cancellable = Set<AnyCancellable>()

	init(dataService: DI) {
		self.dataService = dataService

		Task {
			try await loadCurrentUser()
			try await initDataService()
			try await getAllFriends()
		}
	}

	init(mockService: DI) {
		self.dataService = mockService

		self.currentUser = FFUser.mockUser()
		self.posts = [
			// swiftlint:disable:next line_length
			.init(id: "1", userId: "1", frontCameraImageUrl: "https://picsum.photos/200", frontCameraImagePath: "https://picsum.photos/200", backCameraImageUrl: "https://picsum.photos/200", backCameraImagePath: "https://picsum.photos/200", description: "測試用", createdDate: .now),
			// swiftlint:disable:next line_length
			.init(id: "1", userId: "1", frontCameraImageUrl: "https://picsum.photos/200", frontCameraImagePath: "https://picsum.photos/200", backCameraImageUrl: "https://picsum.photos/200", backCameraImagePath: "https://picsum.photos/200", description: "測試用", createdDate: .now)
		]
	}

	public func reloadData() {
		dataService.getData()
			.sink { error in
				print(error)
			} receiveValue: { [weak self] foodPrints in
				self?.posts = foodPrints
			}
			.store(in: &cancellable)
	}

	private func initDataService() async throws {
		guard 
			let dataService = dataService as? FoodPrintDataService<FoodPrint>,
			let friends = currentUser?.friends
		else {
			return
		}

		try await dataService.getDataFromFirebase(from: friends)

		dataService.getData()
			.sink { error in
				print(error)
			} receiveValue: { [weak self] foodPrints in
				self?.posts = foodPrints
			}
			.store(in: &cancellable)
	}

	private func loadCurrentUser() async throws {
		let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()

		guard let authDataResultModel = authUser else { return }
		self.currentUser = try await UserManager.shared.getUser(userId: authDataResultModel.uid)
	}

	private func getAllFriends() async throws {
		guard let friendsId = currentUser?.friends else { return }

		self.friends = try await UserManager.shared.getUserFriends(ids: friendsId)
	}

	public func getCommentUsers(ids: [String]) async throws -> [FFUser] {
		let users = try await UserManager.shared.getUserFriends(ids: ids)

		return users
	}

}

extension FoodPrintViewModel {
	// MARK: - User actions
	public func leaveComment(foodPrint: FoodPrint, comment: String) {
		guard let currentUser else { return }

		dataService.leaveComment(foodPrint, userId: currentUser.id, comment: comment)
	}

	public func reportFoodPrint(id: String, reason: ReportReason) {
		debugPrint("reported")
		do {
			try ReportManager.shared.report(id: id, type: .foodPrint, reason: reason)
		} catch {
			debugPrint(error)
		}
	}

	public func likePost(foodPrint: FoodPrint) {
		guard let currentUser else { return }

		dataService.likePost(foodPrint, userId: currentUser.id)
	}

	public func dislikePost(foodPrint: FoodPrint) {
		guard let currentUser else { return }

		dataService.dislikePost(foodPrint, userId: currentUser.id)
	}
}
