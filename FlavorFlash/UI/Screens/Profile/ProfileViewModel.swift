//
//  ProfileViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//
import SwiftUI

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
}
