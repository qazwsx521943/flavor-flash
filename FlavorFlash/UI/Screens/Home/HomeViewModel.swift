//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import MapKit
import Vision

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var category: RestaurantCategory?

	@Published var userCategories: [RestaurantCategory] = []

	@Published var currentUser: FFUser?

    @Published var currentLocation: CLLocationCoordinate2D?

    @Published var restaurants: [Restaurant] = []

    @Published var selectedRestaurant: Restaurant?

	@Published var inputImage: UIImage?

	@Published var outputImage: UIImage?

	@Published var userSavedRestaurants: [Restaurant] = []

	init() {
		Task {
			try await loadCurrentUser()
			try await loadUserSavedRestaurants()
		}
	}

    func setRestaurants(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
    }

	func randomCategory() {
		print(userCategories)
		guard !userCategories.isEmpty else { return }
		category = userCategories.randomElement()!
	}

	private func loadCurrentUser() async throws {
		guard let currentUser = try? AuthenticationManager.shared.getAuthenticatedUser() 
		else {
			throw FBAuthError.userNotLoggedIn
		}

		let user = try await UserManager.shared.getUser(userId: currentUser.uid)
		debugPrint("home get user: \(user)")
		await MainActor.run {
			self.currentUser = user
			if let categoryPreferences = user.categoryPreferences {
				self.userCategories = categoryPreferences.compactMap { RestaurantCategory(rawValue: $0) }
			}
		}
	}

	func saveFavoriteRestaurant(_ restaurant: Restaurant) throws {
		guard let currentUser else { return }

		do {
			try UserManager.shared.saveUserFavoriteRestaurant(userId: currentUser.id, restaurant: restaurant)
		} catch {
			throw URLError(.badServerResponse)
		}
	}

	func loadUserSavedRestaurants() async throws {
		print(currentUser?.favoriteRestaurants)
		print("current User",currentUser)
		guard let savedRestaurantIds = currentUser?.favoriteRestaurants else { return }
		print("saved ids: \(savedRestaurantIds)")

		var restaurants: [Restaurant] = []

		try await withThrowingTaskGroup(of: Restaurant.self) { group in
			for id in savedRestaurantIds {
				group.addTask {
					try await PlaceFetcher.shared.fetchPlaceDetailById(id: id)
				}
			}

			for try await restaurant in group {
				restaurants.append(restaurant)
			}

			self.userSavedRestaurants = restaurants
		}
	}
}

// MARK: - Image processing using Vision
extension HomeViewModel {
	func runVisionRequest() {

		guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model)
		else { return }

		let request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete)
		request.imageCropAndScaleOption = .scaleFill

		guard let inputImage else { return }

		DispatchQueue.global().async {

			let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])

			do {
				try handler.perform([request])
			}catch {
				print(error)
			}
		}
	}

	func visionRequestDidComplete(request: VNRequest, error: Error?) {
		guard let inputImage else { return }
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			if let observations = request.results as? [VNCoreMLFeatureValueObservation],
			   let segmentationmap = observations.first?.featureValue.multiArrayValue {

				let segmentationMask = segmentationmap.image(min: 0, max: 1)

				self.outputImage = segmentationMask!.resizedImage(for: inputImage.size)!

//				self.maskOriginalImage()
				self.maskInputImage()
			}
		}
	}

	func maskInputImage() {
		guard
			let inputImage,
			let outputImage
		else { return }

		let bgImage = UIImage.imageFromColor(color: .blue, size: inputImage.size, scale: inputImage.scale)!

		let beginImage = CIImage(cgImage: inputImage.cgImage!)
		let background = CIImage(cgImage: bgImage.cgImage!)
		let mask = CIImage(cgImage: outputImage.cgImage!)

		if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
			kCIInputImageKey: beginImage,
			kCIInputBackgroundImageKey:background,
			kCIInputMaskImageKey:mask])?.outputImage
		{

			let ciContext = CIContext(options: nil)
			let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)

			self.outputImage = UIImage(cgImage: filteredImageRef!)
		}
	}

	func maskOriginalImage() {
		guard
			let inputImage,
			let outputImage
		else { return }

			let maskReference = outputImage.cgImage!
			let imageMask = CGImage(maskWidth: maskReference.width,
									height: maskReference.height,
									bitsPerComponent: maskReference.bitsPerComponent,
									bitsPerPixel: maskReference.bitsPerPixel,
									bytesPerRow: maskReference.bytesPerRow,
									provider: maskReference.dataProvider!, decode: nil, shouldInterpolate: true)

			let maskedReference = inputImage.cgImage!.masking(imageMask!)
		self.outputImage = UIImage(cgImage: maskedReference!)
	}
}
