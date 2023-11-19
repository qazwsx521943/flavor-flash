//
//  UserManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {

	static let shared = UserManager()

	private let userCollection = Firestore.firestore().collection("users")

	private let encoder: Firestore.Encoder = {
		let encoder = Firestore.Encoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}()

	private let decoder: Firestore.Decoder = {
		let decoder = Firestore.Decoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()

	private func userDocument(userId: String) -> DocumentReference {
		userCollection.document(userId)
	}

	private init() { }

	// MARK: - CRUD
	func createNewUser(user: FFUser) async throws {
		debugPrint("creating new user: \(user)")
		try userDocument(userId: user.userId).setData(
			from: user,
			merge: false,
			encoder: encoder)
	}

	func getUser(userId: String) async throws -> FFUser {
		return try await userDocument(userId: userId).getDocument(as: FFUser.self, decoder: decoder)
	}

	// updateDate vs. setData (be careful using setData)
}
