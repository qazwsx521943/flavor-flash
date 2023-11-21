//
//  ProfileViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//
import SwiftUI
import PhotosUI
@MainActor
final class ProfileViewModel: ObservableObject {
	@Published private(set) var user: FFUser?

	func logOut() throws {
		try AuthenticationManager.shared.signOut()
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

	func saveProfileImage(item: PhotosPickerItem) {
		guard let user else { return }

		Task {
			guard let data = try await item.loadTransferable(type: Data.self) else { return }
			let (path, name) = try await StorageManager.shared.saveImage(userId: user.userId, data: data)
			debugPrint("Image saved to path: \(path)!, name: \(name)")
			let url = try await StorageManager.shared.getUrlForImage(path: path)
			try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
			try await loadCurrentUser()
		}
	}
}
