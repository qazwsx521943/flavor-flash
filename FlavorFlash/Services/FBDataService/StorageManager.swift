//
//  StorageManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {

	static let shared = StorageManager()

	private let storageRef = Storage.storage().reference()

	enum MetaDataType: String {
		case jpeg = "image/jpeg"
		case png = "image/png"
	}

	private init() {}

	// MARK: - Private func
	private func userRef(userId: String) -> StorageReference {
		storageRef.child("user").child(userId)
	}

	private func getPathForImage(path: String) -> StorageReference {
		Storage.storage().reference(withPath: path)
	}

	// MARK: - Public func
	public func getUrlForImage(path: String) async throws -> URL {
		try await getPathForImage(path: path).downloadURL()
	}

	public func saveImage(userId: String, data: Data) async throws -> (path: String, name: String) {
		let metaData = StorageMetadata()
		metaData.contentType = MetaDataType.jpeg.rawValue

		let path = "\(UUID().uuidString).jpeg"
		let returnedMetaData = try await userRef(userId: userId).child(path).putDataAsync(data, metadata: metaData)

		guard
			let returnedPath = returnedMetaData.path,
			let returnedName = returnedMetaData.name
		else {
			throw URLError(.badServerResponse)
		}

		return (returnedPath, returnedName)
	}

	public func saveImage(userId: String, image: UIImage) async throws -> (path: String, name: String) {
		// image.pngData()
		guard let data = image.jpegData(compressionQuality: 0.5) else {
			throw URLError(.backgroundSessionWasDisconnected)
		}

		return try await saveImage(userId: userId, data: data)
	}
}
