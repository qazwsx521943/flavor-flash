//
//  AuthenticationManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
	let uid: String
	let email: String?
	let photoUrl: String?

	init(user: User) {
		self.uid = user.uid
		self.email = user.email
		self.photoUrl = user.photoURL?.absoluteString
	}
}

// TODO: use Dependency injection pattern later
final class AuthenticationManager {
	static let shared = AuthenticationManager()

	private init() {}

	// MARK: - helper getter
	func getAuthenticatedUser() throws -> AuthDataResultModel {
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badServerResponse)
		}

		return AuthDataResultModel(user: user)
	}

	// MARK: - CRUD
	@discardableResult
	func createUser(email: String, password: String) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)

		return AuthDataResultModel(user: authDataResult.user)
	}

	@discardableResult
	func signIn(email: String, password: String) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)

		return AuthDataResultModel(user: authDataResult.user)
	}

	func signOut() throws {
		debugPrint("\(Auth.auth().currentUser?.displayName) signing out")
		try Auth.auth().signOut()
	}

	func resetPassword(email: String) async throws {
		try await Auth.auth().sendPasswordReset(withEmail: email)
	}

	func updatePassword(password: String) async throws {
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badServerResponse)
		}

		try await user.updatePassword(to: password)
	}
}
