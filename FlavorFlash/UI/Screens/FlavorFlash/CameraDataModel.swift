//
//  CameraModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import AVFoundation
import SwiftUI
import os.log
import CoreML
import Vision

final class CameraDataModel: ObservableObject {
    let camera = Camera()

	@Published var comment: String = ""

    @Published var viewfinderBackCamImage: Image?

    @Published var viewfinderFrontCamImage: Image?

    @Published var capturedBackCamImage: AVCapturePhoto?

    @Published var capturedFrontCamImage: AVCapturePhoto?

	@Published var foodAnalyzeResult: String = ""

	// MLModel Config
 	let foodClassifier = {
		do {
			let config = MLModelConfiguration()
			return try FoodClassifierV1(configuration: config)
		} catch let error {
			fatalError("something wrong loading model: \(error.localizedDescription)")
		}
	}()

	private var classificationRequest: VNCoreMLRequest?

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

	var frontCamImage: Image? {
		guard
			let captureImage = capturedFrontCamImage,
			let photoData = captureImage.fileDataRepresentation()
		else {
			return nil
		}

		return Image(captureImage.cgImageRepresentation()!, scale: 1, orientation: .right, label: Text("front"))
	}

	var backCamImage: Image? {
		guard
			let captureImage = capturedBackCamImage
		else {
			return nil
		}

		return Image(captureImage.cgImageRepresentation()!, scale: 1, orientation: .right, label: Text("back"))
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

// ML analyzing
extension CameraDataModel {
	func analyzeFood() {
		do {
			let VNModel = try VNCoreMLModel(for: foodClassifier.model)
			let request = VNCoreMLRequest(model: VNModel) { [weak self] request, error in
				self?.processObservations(for: request, error: error)
			}
			request.imageCropAndScaleOption = .scaleFit
			classificationRequest = request
		} catch {
			fatalError("fail analyzing")
		}

		guard
			let pixelBuffer = capturedFrontCamImage?.pixelBuffer
		else {
			return
		}
		let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

		let orientation = CGImagePropertyOrientation.up

		let handler = VNImageRequestHandler(
			ciImage: ciImage,
			orientation: orientation)
		do {
			try handler.perform([classificationRequest!])
		} catch {
			print("Failed to perform classification: \(error)")
		}

	}

	func processObservations(
		for request: VNRequest,
		error: Error?) {
			// 1
			DispatchQueue.main.async { [weak self] in
				// 2
				if let results = request.results
					as? [VNClassificationObservation] {
					// 3
					if results.isEmpty {
						self?.foodAnalyzeResult = "nothing found"
					} else {
						self?.foodAnalyzeResult = String(
							format: "%@ %.1f%%",
							results[0].identifier,
							results[0].confidence * 100)
					}
					// 4
				} else if let error = error {
					self?.foodAnalyzeResult =
					"error: \(error.localizedDescription)"
				} else {
					self?.foodAnalyzeResult = "???"
				}
			}
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
