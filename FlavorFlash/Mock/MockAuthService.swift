//
//  MockAuthService.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2024/1/8.
//

import Foundation
import FirebaseAuth

class MockAuthService: AuthServiceProtocol {
	func getAuthenticatedUser() throws -> AuthDataResultModel {
		return AuthDataResultModel(fbUser: FBUser.mockUser())
	}
	
	func createUser(email: String, password: String) async throws -> AuthDataResultModel {
		AuthDataResultModel(fbUser: FBUser.mockUser())
	}
	
	func signIn(email: String, password: String) async throws -> AuthDataResultModel {
		AuthDataResultModel(fbUser: FBUser.mockUser())
	}
	
	func signOut() throws {

	}
	
	func resetPassword(email: String) async throws {

	}
	
	func updatePassword(password: String) async throws {

	}
	
	func deleteAccount() {

	}
	

}
