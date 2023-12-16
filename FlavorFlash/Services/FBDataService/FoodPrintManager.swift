//
//  FoodPrintManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/14.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class FoodPrintManager {
	static let shared = FoodPrintManager()

	private let foodPrintCollection = Firestore.firestore().collection("foodprints")

	private init() {}

	func getUserPosts(including usersId: [String]) async throws -> [FBFoodPrint] {
		let snapshot = try await foodPrintCollection.whereField("user_id", in: usersId).getDocuments()

		let posts = snapshot.documents.compactMap { try? $0.data(as: FBFoodPrint.self) }

		return posts
	}
}
