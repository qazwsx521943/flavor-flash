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
