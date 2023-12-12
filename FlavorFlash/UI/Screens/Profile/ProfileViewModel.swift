//
//  ProfileViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//
import SwiftUI
import PhotosUI
import UIKit
import CoreImage.CIFilterBuiltins
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
	@Published private(set) var user: FFUser?

	@Published var searchedUser: FFUser?

	@Published var friends: [FFUser] = []

	@Published var blockedUsers: [FFUser] = []

	@Published var foodPrints: [FoodPrint] = []

	@Published var friendFoodPrints: [FoodPrint] = []

	init() {
		loadProfileData()
	}

	public func loadProfileData() {
		Task {
			try? await loadCurrentUser()
			try? await getFoodPrints()
			try? await loadBlockedUser()
		}
	}

	func logOut() throws {
		try AuthenticationManager.shared.signOut()
		user = nil
	}

	func resetPassword() async throws {
		let authUser = try AuthenticationManager.shared.getAuthenticatedUser()

		guard let email = authUser.email else {
			throw(URLError(.cancelled))
		}

		try await AuthenticationManager.shared.resetPassword(email: email)
	}

	func loadCurrentUser() async throws {
		let authUser = try AuthenticationManager.shared.getAuthenticatedUser()

		self.user = try await UserManager.shared.getUser(userId: authUser.uid)
	}

	func loadBlockedUser() async throws {
		guard let blockedIds = self.user?.blockedList else { return }
		self.blockedUsers = try await UserManager.shared.getUserFriends(ids: blockedIds)
	}

	func saveProfileImage(item: PhotosPickerItem) {
		guard let user else { return }

		Task {
			guard let data = try await item.loadTransferable(type: Data.self) else { return }
			let (path, name) = try await StorageManager.shared.saveImage(userId: user.id, data: data)
			debugPrint("Image saved to path: \(path)!, name: \(name)")
			let url = try await StorageManager.shared.getUrlForImage(path: path)
			try await UserManager.shared.updateUserProfileImagePath(userId: user.id, path: path, url: url.absoluteString)
			try await loadCurrentUser()
		}
	}

	func generateQRCode(from string: String) -> UIImage {
		let context = CIContext()
		let filter = CIFilter.qrCodeGenerator()

		filter.message = Data(string.utf8)

		if let outputImage = filter.outputImage {
			if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
				return UIImage(cgImage: cgImage)
			}
		}

		return UIImage(systemName: "xmark.circle") ?? UIImage()
	}

	func getUser(userId: String) async throws -> FFUser {
		do {
			let user = try await UserManager.shared.getUser(userId: userId)
			return user
		} catch {
			print("error getting User \(userId): \(error.localizedDescription)")
			throw URLError(.badServerResponse)
		}
	}

	func sendRequest(to userId: String) async throws {
		guard let currentUserId = user?.id else { return }
		try await UserManager.shared.addFriend(userId: userId, from: currentUserId)
	}

	// task groups
	func getAllFriends() async throws {
		guard let friendsId = user?.friends else { return }

		self.friends = try await UserManager.shared.getUserFriends(ids: friendsId)
	}

	func getFoodPrints() async throws {
		guard let userId = user?.id else { return }
		self.foodPrints = try await FoodPrintManager.shared.getUserPosts(including: [userId])
		debugPrint(foodPrints)
	}

	func getFriendFoodPrint(userId: String) async throws {
		self.friendFoodPrints = try await FoodPrintManager.shared.getUserPosts(including: [userId])
	}
}

// MARK: - Auth function
extension ProfileViewModel {
	func deleteAccount() {
		AuthenticationManager.shared.deleteAccount()
		user = nil
	}
}

// MARK: - UGC conform
extension ProfileViewModel {
	public func blockFriend(_ id: String) {
		guard let userId = user?.id else { return }
		Task {
			try await UserManager.shared.blockFriend(blockId: id, from: userId)
			try await ChatManager.shared.deleteGroup(with: id, from: userId)
			loadProfileData()
		}
	}

	public func deleteFriend(_ id: String) {
		guard let userId = user?.id else { return }
		Task {
			try await UserManager.shared.deleteFriend(deleteId: id, from: userId)
			loadProfileData()
		}
	}
}
