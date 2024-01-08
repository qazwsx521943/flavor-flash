//
//  AuthenticationManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import OSLog

enum FBAuthError: Error {
	case signInError
	case inputFieldEmpty
	case userNotLoggedIn
	case signInWithAppleError
}

enum AuthProviderOption: String {
	case email = "password"
	// TODO: - Google sign in
	case google = "google.com"
	case apple = "apple.com"
}

struct AuthDataResultModel {
	let uid: String
	let email: String?
	let photoUrl: String?

	init(user: User) {
		self.uid = user.uid
		self.email = user.email
		self.photoUrl = user.photoURL?.absoluteString
	}

	// for unit testing
	init(fbUser: FBUser) {
		self.uid = fbUser.id
		self.email = fbUser.email
		self.photoUrl = fbUser.profileImageUrl
	}
}

protocol AuthServiceProtocol {
	func getAuthenticatedUser() throws -> AuthDataResultModel
	func createUser(email: String, password: String) async throws -> AuthDataResultModel
	func signIn(email: String, password: String) async throws -> AuthDataResultModel
	func signOut() throws
	func resetPassword(email: String) async throws
	func updatePassword(password: String) async throws
	func deleteAccount()
}

// TODO: use Dependency injection pattern later
final class AuthenticationManager: AuthServiceProtocol {
	static let shared = AuthenticationManager()

	private init() {}

	// MARK: - helper getter
	func getAuthenticatedUser() throws -> AuthDataResultModel {
		guard let user = Auth.auth().currentUser else {
			throw FBAuthError.userNotLoggedIn
		}
		logger.info("Current Logged in UserID: \(user.uid)")

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
		do {
			let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
			
			return AuthDataResultModel(user: authDataResult.user)
		} catch {
			logger.error("\(FBAuthError.signInError)")
			throw FBAuthError.signInError
		}
	}

	func signOut() throws {
		guard let user = Auth.auth().currentUser else {
			throw FBAuthError.userNotLoggedIn
		}
		logger.info("\(user.uid) signing out")
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

	func deleteAccount() {
		guard let user = Auth.auth().currentUser else {
			return
		}
		Auth.auth().currentUser?.delete()
		logger.info("\(user.uid) deleted account")
	}
}

// MARK: - Sign in SSO
extension AuthenticationManager {
	@discardableResult
	func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {

		let credential = OAuthProvider.appleCredential(
			withIDToken: tokens.token,
			rawNonce: tokens.nonce,
			fullName: tokens.fullName)

		return try await signIn(credential: credential)
	}

	func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().signIn(with: credential)
		return AuthDataResultModel(user: authDataResult.user)
	}
}

extension AuthenticationManager {

	func sendTokenToServer(token: String?) {
		guard let token else {
			logger.info("FCM Token is nil")
			return
		}

		let deviceToken: [String: Any] = [
			"token": token,
			"timestamp": FieldValue.serverTimestamp()
		]

		if let userId = Auth.auth().currentUser?.uid {
			let fcmTokensCollection = Firestore.firestore().collection("fcmTokens")
			let documentRef = fcmTokensCollection.document(userId)

			documentRef.setData(deviceToken) { error in
				if let error = error {
					print("Error setting FCM token data: \(error)")
				} else {
					print("FCM token data set successfully.")
				}
			}
		}
	}
}

fileprivate let logger = Logger(subsystem: "ios22-jason.FlavorFlash", category: "AuthenticationManager")
