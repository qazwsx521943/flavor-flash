//
//  CameraModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import AVFoundation
import SwiftUI
import os.log

final class CameraDataModel: ObservableObject {
    let camera = Camera()

	@Published var comment: String = ""

    @Published var viewfinderBackCamImage: Image?

    @Published var viewfinderFrontCamImage: Image?

    @Published var capturedBackCamImage: AVCapturePhoto?

    @Published var capturedFrontCamImage: AVCapturePhoto?

    init() {
        camera.frontCamCapturedImage = { capturedImage in
            self.capturedFrontCamImage = capturedImage
        }

        camera.backCamCapturedImage = { capturedImage in
            self.capturedBackCamImage = capturedImage
        }

        Task {
            await handleBackCameraPreviews()
        }
        Task {
            await handleFrontCameraPreviews()
        }
    }

    // handle camera previews
    func handleBackCameraPreviews() async {
        let backCamImageStream = camera.backCamPreviewStream.map { $0.image }

        for await image in backCamImageStream {
            Task { @MainActor in
                viewfinderBackCamImage = image
            }
        }
    }

    func handleFrontCameraPreviews() async {
        let frontCamImageStream = camera.frontCamPreviewStream.map { $0.image }

        for await image in frontCamImageStream {
            Task { @MainActor in
                viewfinderFrontCamImage = image
            }
        }
    }

	var frontCamImage: Image {
		Image(uiImage: UIImage(cgImage: capturedFrontCamImage!.cgImageRepresentation()!))
	}
	var backCamImage: Image {
		Image(uiImage: UIImage(cgImage: capturedBackCamImage!.cgImageRepresentation()!))
	}

	func saveImages() async throws {
		let authResultModel = try AuthenticationManager.shared.getAuthenticatedUser()

		let userId = authResultModel.uid

		guard
			let fcImage = capturedFrontCamImage?.cgImageRepresentation(),
			let bcImage = capturedBackCamImage?.cgImageRepresentation()
		else {
			return
		}
		let frontImage = UIImage(cgImage: fcImage)
		let backImage = UIImage(cgImage: bcImage)
		let (frontImagePath, frontImageName) = try await StorageManager.shared.saveImage(userId: userId, image: frontImage)
		let (backImagePath, backImageName) = try await StorageManager.shared.saveImage(userId: userId, image: backImage)

		let frontUrl = try await StorageManager.shared.getUrlForImage(path: frontImagePath)
		let backUrl = try await StorageManager.shared.getUrlForImage(path: frontImagePath)
		let foodPrint = FoodPrint(
			id: UUID().uuidString,
			frontCameraImageUrl: frontUrl.absoluteString,
			frontCameraImagePath: frontImagePath,
			backCameraImageUrl: backUrl.absoluteString,
			backCameraImagePath: backImagePath,
			comment: comment,
			createdDate: Date())

		try await UserManager.shared.saveUserFoodPrint(userId: userId, foodPrint: foodPrint)
	}
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

	init(_ cgImageOrientation: CGImagePropertyOrientation) {
		switch cgImageOrientation {
		case .up: self = .up
		case .upMirrored: self = .upMirrored
		case .down: self = .down
		case .downMirrored: self = .downMirrored
		case .left: self = .left
		case .leftMirrored: self = .leftMirrored
		case .right: self = .right
		case .rightMirrored: self = .rightMirrored
		}
	}
}

fileprivate let logger = Logger(subsystem: "flavor-flash.capturingPhotos", category: "CameraDataModel")
