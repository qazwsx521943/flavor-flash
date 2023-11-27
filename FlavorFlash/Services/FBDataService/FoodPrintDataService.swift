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
		$items.tryMap{ $0 }.eraseToAnyPublisher()
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

	func add(_ item: T) {
		do {
			_ = try store.collection(path).addDocument(from: item)
		} catch {
			fatalError("Adding an item failed")
		}
	}

	func delete(_ item: T) {
		//		guard let documentID = item.id else { return }
		let documentID = item.id
		store.collection(path).document(documentID).delete { error in
			if let error = error {
				print("Unable to remove fbmask: \(error.localizedDescription)")
			}
		}
	}

	func update(_ item: T) {
		//		guard let documentID = item.id else { return }
		let documentID = item.id
		do {
			try store.collection(path).document(documentID).setData(from: item)

		} catch {
			fatalError("Updating item failed")
		}
	}
}
