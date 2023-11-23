//
//  Camera.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import AVFoundation
import CoreImage
import UIKit
import os.log

class Camera: NSObject {
	// A capture Session must have at least one input & one output
	// multiple camera session
	private let multiCamSession = AVCaptureMultiCamSession()
	// Inputs
	private var backCamDeviceInput: AVCaptureDeviceInput?
	private var frontCamDeviceInput: AVCaptureDeviceInput?
	// Outputs
	private var backCamPhotoOutput: AVCapturePhotoOutput?
	private var frontCamPhotoOutput: AVCapturePhotoOutput?
	// preview stream initialization
	private var backCamVideoDataOutput: AVCaptureVideoDataOutput?
	private var frontCamVideoDataOutput: AVCaptureVideoDataOutput?

	// MARK: - Capture device setup
	private var allCaptureDevices: [AVCaptureDevice] {
		AVCaptureDevice.DiscoverySession(
			deviceTypes: [
				.builtInTrueDepthCamera,
				.builtInDualCamera,
				.builtInDualWideCamera,
				.builtInWideAngleCamera,
				.builtInDualWideCamera
			],
			mediaType: .video,
			position: .unspecified).devices
	}

	private var frontCaptureDevices: [AVCaptureDevice] {
		allCaptureDevices
			.filter { $0.position == .front }
	}

	private var backCaptureDevices: [AVCaptureDevice] {
		allCaptureDevices
			.filter { $0.position == .back }
	}

	private var captureDevices: [AVCaptureDevice] {
		var devices = [AVCaptureDevice]()
#if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
		devices += allCaptureDevices
#else
		if let backDevice = backCaptureDevices.first {
			devices += [backDevice]
		}
		if let frontDevice = frontCaptureDevices.first {
			devices += [frontDevice]
		}
#endif
		return devices
	}

	private var availableCaptureDevices: [AVCaptureDevice] {
		captureDevices
			.filter( { $0.isConnected } )
			.filter( { !$0.isSuspended } )
	}

	private var frontCaptureDevice: AVCaptureDevice?
	private var backCaptureDevice: AVCaptureDevice?

	// MARK: - Preview status control
	var isPreviewPaused = false

	private var isMultiCaptureSessionConfigured = false

	// MARK: - Helper getter
	var isRunning: Bool {
		multiCamSession.isRunning
	}

	// Custom Queues
	private let captureSessionQueue = DispatchQueue(label: "capture session queue")
	private let dataOutputQueue = DispatchQueue(label: "data output queue")

	// MARK: - Preview Stream setup
	private var addToFrontCamPreviewStream: ((CIImage) -> Void)?
	private var addToBackCamPreviewStream: ((CIImage) -> Void)?

	var frontCamCapturedImage: ((AVCapturePhoto) -> Void)?
	var backCamCapturedImage: ((AVCapturePhoto) -> Void)?

	lazy var frontCamPreviewStream: AsyncStream<CIImage> = {
		AsyncStream { continuation in
			addToFrontCamPreviewStream = { ciImage in
				if !self.isPreviewPaused {
					continuation.yield(ciImage)
				}
			}
		}
	}()

	lazy var backCamPreviewStream: AsyncStream<CIImage> = {
		AsyncStream { continuation in
			addToBackCamPreviewStream = { ciImage in
				if !self.isPreviewPaused {
					continuation.yield(ciImage)
				}
			}
		}
	}()

	// MARK: - Initializers
	override init() {
		super.init()
		initialize()
	}

	private func initialize() {
		frontCaptureDevice = frontCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
		backCaptureDevice = backCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
	}

	// MARK: - Camera Actions
	func start() async {
		let authorized = await checkAuthorization()
		guard authorized else {
			logger.error("Camera access is not authorized by user")
			return
		}

		// if capture session is configured, just start the session
		if isMultiCaptureSessionConfigured {
			if !multiCamSession.isRunning {
				captureSessionQueue.async {
					self.multiCamSession.startRunning()
				}
			}
			return
		}

		// else configure a capture session
		captureSessionQueue.async {
			self.configureCaptureSession { success in
				guard success else { return }
				self.multiCamSession.startRunning()
			}
		}
	}

	func stop() {
		guard isMultiCaptureSessionConfigured else { return }

		if multiCamSession.isRunning {
			captureSessionQueue.async {
				self.multiCamSession.stopRunning()
			}
		}
	}

	func takePhoto() {
		guard
			let backCamPhotoOutput = self.backCamPhotoOutput,
			let frontCamPhotoOutput = self.frontCamPhotoOutput
		else {
			return
		}

		captureSessionQueue.async {
			var photoSettings = AVCapturePhotoSettings()

			let kCVPixelFormat = kCVPixelFormatType_32BGRA

			if
				backCamPhotoOutput.availablePhotoPixelFormatTypes.contains(kCVPixelFormat),
				frontCamPhotoOutput.availablePhotoPixelFormatTypes.contains(kCVPixelFormat)
			{
				photoSettings = AVCapturePhotoSettings(format: [
					kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormat
				])
			}

			let isFlashAvailable = self.backCamDeviceInput?.device.isFlashAvailable ?? false
			photoSettings.flashMode = isFlashAvailable ? .auto : .off
			photoSettings.isHighResolutionPhotoEnabled = true

			if
				let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
				photoSettings.previewPhotoFormat =
				[kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
			}
			photoSettings.photoQualityPrioritization = .balanced

			if let photoOutputVideoConnection = backCamPhotoOutput.connection(with: .video) {
				if photoOutputVideoConnection.isVideoOrientationSupported,
				   let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
					photoOutputVideoConnection.videoOrientation = videoOrientation
				}
			}
			if let photoOutputVideoConnection = frontCamPhotoOutput.connection(with: .video) {
				if photoOutputVideoConnection.isVideoOrientationSupported,
				   let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
					photoOutputVideoConnection.videoOrientation = videoOrientation
				}
			}

			frontCamPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
			backCamPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
		}
	}

	// MARK: - Capture Session configs
	private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {

		guard AVCaptureMultiCamSession.isMultiCamSupported else {
			logger.error("MultiCam not supported")
			return
		}

		var success = false

		self.multiCamSession.beginConfiguration()

		defer {
			self.multiCamSession.commitConfiguration()
			completionHandler(success)
		}

		guard configureBackCamera() else {
			logger.error("Cannot configure back camera")
			return
		}
		guard configureFrontCamera() else {
			logger.error("Cannot configure front camera")
			return
		}

		updateVideoOutputConnection()

		// capture session configured
		isMultiCaptureSessionConfigured = true

		success = true
	}

	private func updateVideoOutputConnection() {
		if let videoOutput = frontCamVideoDataOutput,
		   let videoOutputConnection = videoOutput.connection(with: .video) {
			if videoOutputConnection.isVideoMirroringSupported {
				videoOutputConnection.isVideoMirrored = true
			}
		}
	}

	// MARK: - Device input setup
	private func configureBackCamera() -> Bool {

		multiCamSession.beginConfiguration()

		defer {
			multiCamSession.commitConfiguration()
		}

		guard
			let backCaptureDevice = backCaptureDevice,
			let backCamDeviceInput = try? AVCaptureDeviceInput(device: backCaptureDevice)
		else {
			logger.error("Cannot find the back camera")
			return false
		}

		let backCamPhotoOutput = AVCapturePhotoOutput()
		backCamPhotoOutput.isHighResolutionCaptureEnabled = true
		backCamPhotoOutput.maxPhotoQualityPrioritization = .quality

		let backCamVideoDataOutput = AVCaptureVideoDataOutput()
		backCamVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)

		// check if the current multiCameraSession is able to add input and output
		guard multiCamSession.canAddInput(backCamDeviceInput) else {
			logger.error("Cannot add back camera device input")
			return false
		}

		guard multiCamSession.canAddOutput(backCamPhotoOutput) else {
			logger.error("Cannot add back camera photo output")
			return false
		}

		guard multiCamSession.canAddOutput(backCamVideoDataOutput) else {
			logger.error("Cannot add back camera video data output")
			return false
		}

		// if can add, add current device input/output to the current multiCameraSession
		multiCamSession.addInput(backCamDeviceInput)
		multiCamSession.addOutput(backCamPhotoOutput)
		multiCamSession.addOutput(backCamVideoDataOutput)

		self.backCamDeviceInput = backCamDeviceInput
		self.backCamPhotoOutput = backCamPhotoOutput
		self.backCamVideoDataOutput = backCamVideoDataOutput

		return true
	}

	private func configureFrontCamera() -> Bool {

		multiCamSession.beginConfiguration()

		defer {
			multiCamSession.commitConfiguration()
		}

		guard
			let frontCaptureDevice = frontCaptureDevice,
			let frontCamDeviceInput = try? AVCaptureDeviceInput(device: frontCaptureDevice)
		else {
			logger.error("Cannot find the front camera")
			return false
		}

		let frontCamPhotoOutput = AVCapturePhotoOutput()
		frontCamPhotoOutput.isHighResolutionCaptureEnabled = true
		frontCamPhotoOutput.maxPhotoQualityPrioritization = .quality

		let frontCamVideoDataOutput = AVCaptureVideoDataOutput()
		frontCamVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)

		// check if the current multiCameraSession is able to add input and output
		guard multiCamSession.canAddInput(frontCamDeviceInput) else {
			logger.error("Cannot add front camera device input")
			return false
		}

		guard multiCamSession.canAddOutput(frontCamPhotoOutput) else {
			logger.error("Cannot add front camera photo output")
			return false
		}

		guard multiCamSession.canAddOutput(frontCamVideoDataOutput) else {
			logger.error("Cannot add front camera video data output")
			return false
		}

		// if can add, add current device input/output to the current multiCameraSession
		multiCamSession.addInput(frontCamDeviceInput)
		multiCamSession.addOutput(frontCamPhotoOutput)
		multiCamSession.addOutput(frontCamVideoDataOutput)

		self.frontCamDeviceInput = frontCamDeviceInput
		self.frontCamPhotoOutput = frontCamPhotoOutput
		self.frontCamVideoDataOutput = frontCamVideoDataOutput

		return true
	}

	// get deviceInput by capture device
	private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
		guard let validDevice = device else { return nil }
		do {
			return try AVCaptureDeviceInput(device: validDevice)
		} catch let error {
			logger.error("Error getting capture device input: \(error.localizedDescription)")
			return nil
		}
	}

	// Authorization check
	private func checkAuthorization() async -> Bool {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			logger.debug("Camera access authorized.")
			return true
		case .notDetermined:
			logger.debug("Camera access not determined.")
			captureSessionQueue.suspend()
			let status = await AVCaptureDevice.requestAccess(for: .video)
			captureSessionQueue.resume()
			return status
		case .denied:
			logger.debug("Camera access denied.")
			return false
		case .restricted:
			logger.debug("Camera library access restricted.")
			return false
		@unknown default:
			return false
		}
	}

	// Device and video orientation setup
	private var deviceOrientation: UIDeviceOrientation {
		var orientation = UIDevice.current.orientation
		if orientation == UIDeviceOrientation.unknown {
			orientation = UIScreen.main.orientation
		}
		return orientation
	}

	private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
		switch deviceOrientation {
		case .portrait: return AVCaptureVideoOrientation.portrait
		case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
		case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
		case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
		default: return nil
		}
	}
}

// MARK: - PhotoCapture Delegate
extension Camera: AVCapturePhotoCaptureDelegate {

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

		if let error = error {
			logger.error("Error capturing photo: \(error.localizedDescription)")
			return
		}

//		guard let photoData = photo.fileDataRepresentation() else {
//			return
//		}
//
//		let image = UIImage(data: photoData)
//
//		var previewPhotoOrientation: CGImagePropertyOrientation?
//		if let orientationNum = photo.metadata[kCGImagePropertyOrientation as String] as? NSNumber {
//			debugPrint(orientationNum)
//		}

		if output == backCamPhotoOutput {
			backCamCapturedImage?(photo)
		} else {
			frontCamCapturedImage?(photo)
		}
	}
}

// MARK: - VideoDataOutput
extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {

	func captureOutput(
		_ output: AVCaptureOutput,
		didOutput sampleBuffer: CMSampleBuffer,
		from connection: AVCaptureConnection
	) {
		guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

		if 
			connection.isVideoOrientationSupported,
			let videoOrientation = videoOrientationFor(deviceOrientation) {

			connection.videoOrientation = videoOrientation

		}

		guard let videoDataOutput = output as? AVCaptureVideoDataOutput else { return }

		if videoDataOutput == backCamVideoDataOutput {
			addToBackCamPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
		} else {
			addToFrontCamPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
		}
	}
}

fileprivate extension UIScreen {

	var orientation: UIDeviceOrientation {
		let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
		if point == CGPoint.zero {
			return .portrait
		} else if point.x != 0 && point.y != 0 {
			return .portraitUpsideDown
		} else if point.x == 0 && point.y != 0 {
			return .landscapeRight
		} else if point.x != 0 && point.y == 0 {
			return .landscapeLeft
		} else {
			return .unknown
		}
	}
}

fileprivate let logger = Logger(subsystem: "flavor-flash.capturingPhotos", category: "Camera")
