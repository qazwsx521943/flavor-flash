//
//  ProfileViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//
import SwiftUI
import PhotosUI
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
	@Published private(set) var user: FFUser? {
		didSet {
			guard let userId = user?.userId else { return }
			self.qrCodeImageData = generateQRCode(from: userId)
		}
	}

	@Published var qrCodeImageData: Data?

	func logOut() throws {
		try AuthenticationManager.shared.signOut()
		user = nil
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

	func saveProfileImage(item: PhotosPickerItem) {
		guard let user else { return }

		Task {
			guard let data = try await item.loadTransferable(type: Data.self) else { return }
			let (path, name) = try await StorageManager.shared.saveImage(userId: user.userId, data: data)
			debugPrint("Image saved to path: \(path)!, name: \(name)")
			let url = try await StorageManager.shared.getUrlForImage(path: path)
			try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
			try await loadCurrentUser()
		}
	}
	func generateQRCode(from string: String) -> Data? {
		let data = string.data(using: String.Encoding.ascii)

		if let filter = CIFilter(name: "CIQRCodeGenerator") {
			filter.setValue(data, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 3, y: 3)

			if let output = filter.outputImage?.transformed(by: transform) {
				debugPrint("output qrcode")
				return UIImage(ciImage: output).pngData()
			}
		}

		return nil
	}

	func getUser(userId: String) async throws -> FFUser {
		do {
			let user = try await UserManager.shared.getUser(userId: userId)
			return user
		} catch {
			throw URLError(.badServerResponse)
		}
	}
}
