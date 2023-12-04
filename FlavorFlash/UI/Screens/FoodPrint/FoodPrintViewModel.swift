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
	@Published private(set) var posts: [FoodPrint] = []

	@Published var currentUser: FFUser?

	private let dataService: DI
	private var cancellable = Set<AnyCancellable>()

	init(dataService: DI) {
		self.dataService = dataService

		Task {
			try await loadCurrentUser()
			try await initDataService()
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
}

extension FoodPrintViewModel {
	func reportFoodPrint(id: String, reason: ReportReason) {
		debugPrint("reported")
		do {
			try ReportManager.shared.report(id: id, type: .foodPrint, reason: reason)
		} catch {
			debugPrint(error)
		}
	}
}
