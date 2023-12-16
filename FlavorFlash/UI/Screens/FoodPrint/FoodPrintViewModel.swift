//
//  FoodPrintViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import SwiftUI
import Combine

@MainActor
class FoodPrintViewModel<DI: FBDataService>: ObservableObject where DI.Item == FBFoodPrint {
	@Published var posts: [FBFoodPrint] = []

	@Published var currentUser: FBUser?

	private let dataService: DI

	private var cancellable = Set<AnyCancellable>()

	init(dataService: DI) {
		self.dataService = dataService

		self.reloadData()
	}

	init(mockService: DI) {
		self.dataService = mockService

		self.currentUser = FBUser.mockUser()
		self.posts = [
			// swiftlint:disable:next line_length
			.init(id: "1", userId: "1", username: "GodJJ", frontCameraImageUrl: "https://picsum.photos/200", frontCameraImagePath: "https://picsum.photos/200", backCameraImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/flavorflash-4a1fc.appspot.com/o/user%2FBG0mgz7itQNfjPp0F2jmlECbks22%2F63BC07A6-46DF-4A28-BF93-5DAE5410787D.jpeg?alt=media&token=475c5f85-83e7-4775-8ce2-502cf1292def", backCameraImagePath: "https://picsum.photos/200", description: "測試用", createdDate: .now),
			// swiftlint:disable:next line_length
			.init(id: "1", userId: "1", username: "GodJJ", frontCameraImageUrl: "https://picsum.photos/200", frontCameraImagePath: "https://picsum.photos/200", backCameraImageUrl: "https://picsum.photos/200", backCameraImagePath: "https://picsum.photos/200", description: "測試用", createdDate: .now)
		]
	}

	private func initDataService() async throws {
		guard 
			let dataService = dataService as? FoodPrintDataService<FBFoodPrint>,
			let friends = currentUser?.friends,
			let currentUser
		else {
			return
		}
		let fetchPostsFromIds = friends + [currentUser.id]
		try await dataService.getDataFromFirebase(from: fetchPostsFromIds)

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
}

extension FoodPrintViewModel {
	// MARK: - User actions
	public func reloadData() {
		Task {
			try await loadCurrentUser()
			try await initDataService()
		}
	}

	public func leaveComment(foodPrint: FBFoodPrint, comment: String) {
		guard let currentUser else { return }

		dataService.leaveComment(
			foodPrint, userId: currentUser.id,
			username: currentUser.username,
			userProfileImage: currentUser.profileImageUrl,
			comment: comment)
	}

	public func reportFoodPrint(id: String, reason: ReportReason) {
		debugPrint("reported")
		do {
			try ReportManager.shared.report(id: id, type: .foodPrint, reason: reason)
		} catch {
			debugPrint(error)
		}
	}

	public func likePost(foodPrint: FBFoodPrint) {
		guard let currentUser else { return }

		dataService.likePost(foodPrint, userId: currentUser.id)
	}

	public func dislikePost(foodPrint: FBFoodPrint) {
		guard let currentUser else { return }

		dataService.dislikePost(foodPrint, userId: currentUser.id)
	}
}
