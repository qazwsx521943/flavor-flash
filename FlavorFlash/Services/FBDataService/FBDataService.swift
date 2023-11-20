//
//  FBDataService.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol DataService: ObservableObject {
	associatedtype Item: FBModelType

	func getData()->AnyPublisher<[Item], Error>
	func add(_ item: Item)
	func update(_ item: Item)
	func delete(_ item: Item)
}

protocol FBModelType: Identifiable, Codable {
	var id: String? { set get }
}

class FBDataService<T: FBModelType>: ObservableObject, DataService {
	private let path: String //Name of the firebase collection.
	private let store = Firestore.firestore()

	@Published var items: [T] = []

	init(path: String) {
		self.path = path
		getDataFromFirebase()
	}

	func getData() -> AnyPublisher<[T], Error> {
		$items.tryMap{$0}.eraseToAnyPublisher()
	}

	func getDataFromFirebase() {
		store.collection(path).addSnapshotListener { (snapshot, error) in
			if let error  = error {
				print(error)
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
		guard let documentID = item.id else { return }
		store.collection(path).document(documentID).delete { error in
			if let error = error {
				print("Unable to remove fbmask: \(error.localizedDescription)")
			}
		}
	}

	func update(_ item: T) {
		guard let documentID = item.id else { return }
		do {
			try store.collection(path).document(documentID).setData(from: item)

		} catch {
			fatalError("Updating item failed")
		}
	}
}
