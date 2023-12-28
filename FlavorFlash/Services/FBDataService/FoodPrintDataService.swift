//
//  FoodPrintDataService.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FoodPrintDataService<T: FBModelType>: FBDataService {
	private let path: String //Name of the firebase collection.
	private let store = Firestore.firestore()

	@Published var items: [T] = []

	init(path: String) {
		self.path = path
	}

	func getData() -> AnyPublisher<[T], Error> {
		$items.tryMap { $0 }.eraseToAnyPublisher()
	}

	func getDataFromFirebase(from friends: [String]) async throws {
		store.collection(path)
			.whereField("user_id", in: friends)
			.addSnapshotListener { (snapshot, error) in
				if let error  = error {
					print(error.localizedDescription)
					return
				}
				self.items = snapshot?.documents.compactMap {
					try? $0.data(as: T.self)
				} ?? []
			}
	}

	func likePost(_ item: T, userId: String) {
		let documentID = item.id

		store
			.collection(path)
			.document(documentID)
			.updateData(["liked_by": FieldValue.arrayUnion([userId])])
	}

	func dislikePost(_ item: T, userId: String) {
		let documentID = item.id

		store.collection(path)
			.document(documentID)
			.updateData(["liked_by": FieldValue.arrayRemove([userId])])
	}

	func leaveComment(_ item: T, userId: String, username: String, userProfileImage: String?, comment: String) {
		let documentID = item.id

		let fbComment = FBComment(
			id: UUID().uuidString,
			userId: userId,
			username: username,
			userProfileImage: userProfileImage,
			comment: comment,
			createdDate: Date.now)

		let encodedComment = try? Firestore.Encoder().encode(fbComment)

		guard let encodedComment else { return }

		do {
			store
				.collection(path)
				.document(documentID)
				.updateData([
					"comments": FieldValue.arrayUnion([encodedComment])
				])
		} catch {
			fatalError("adding comment failed")
		}
	}
}
