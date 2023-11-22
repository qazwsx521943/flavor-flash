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
    private let captureSessionQueue = DispatchQueue(label: "capture session queue")
    private let dataOutputQueue = DispatchQueue(label: "data output queue")
    // Inputs
    private var deviceInput: AVCaptureDeviceInput?
    private var backCameraDeviceInput: AVCaptureDeviceInput?
    private var frontCameraDeviceInput: AVCaptureDeviceInput?
    // Outputs
    private var backCamPhotoOutput: AVCapturePhotoOutput?
    private var frontCamPhotoOutput: AVCapturePhotoOutput?
    private let backCameraVideoDataOutput = AVCaptureVideoDataOutput()
    private let frontCameraVideoDataOutput = AVCaptureVideoDataOutput()
    private var videoOutput: AVCaptureVideoDataOutput?

    // MARK: - Capturing Session status
    var isFrontCamPreviewPaused = false
    var isBackCamPreviewPaused = false

    private var isMultiCaptureSessionConfigured = false

    var isRunning: Bool {
        multiCamSession.isRunning
    }

    // MARK: - Preview Stream setup
    private var addToFrontCamPreviewStream: ((CIImage) -> Void)?
    private var addToBackCamPreviewStream: ((CIImage) -> Void)?

    var frontCamCapturedImage: ((AVCapturePhoto) -> Void)?
    var backCamCapturedImage: ((AVCapturePhoto) -> Void)?

    lazy var frontCamPreviewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToFrontCamPreviewStream = { ciImage in
                if !self.isFrontCamPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()

    lazy var backCamPreviewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToBackCamPreviewStream = { ciImage in
                if !self.isBackCamPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()

    // MARK: - Initializers
    override init() {
        super.init()
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
        else { return }

        captureSessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()

            let availableFormat = kCVPixelFormatType_32BGRA
            photoSettings = AVCapturePhotoSettings(format: [
                kCVPixelBufferPixelFormatTypeKey as String: availableFormat
            ])

            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
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

        let BCPhotoOutput = AVCapturePhotoOutput()
        let FCPhotoOutput = AVCapturePhotoOutput()

        guard
            multiCamSession.canAddOutput(FCPhotoOutput),
            multiCamSession.canAddOutput(BCPhotoOutput)
        else {
            logger.error("Unable to add photo output to capture session.")
            return
        }

        multiCamSession.addOutput(FCPhotoOutput)
        multiCamSession.addOutput(BCPhotoOutput)

        self.backCamPhotoOutput = BCPhotoOutput
        self.frontCamPhotoOutput = FCPhotoOutput

        FCPhotoOutput.isHighResolutionCaptureEnabled = true
        FCPhotoOutput.maxPhotoQualityPrioritization = .quality
        BCPhotoOutput.isHighResolutionCaptureEnabled = true
        BCPhotoOutput.maxPhotoQualityPrioritization = .quality

        // capture session configured
        isMultiCaptureSessionConfigured = true

        success = true
    }

    // MARK: - Device input setup
    private func configureBackCamera() -> Bool {
        multiCamSession.beginConfiguration()
        defer {
            multiCamSession.commitConfiguration()
        }

        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        else {
            logger.error("Cannot find the back camera")
            return false
        }

        do {
            backCameraDeviceInput = try AVCaptureDeviceInput(device: backCamera)

            guard
                let backCameraDeviceInput = backCameraDeviceInput,
                multiCamSession.canAddInput(backCameraDeviceInput)
            else {
                logger.error("Cannot add back camera device input")
                return false
            }

            multiCamSession.addInput(backCameraDeviceInput)

        } catch {
            logger.warning("Cannot create back camera device input")
            return false
        }

        guard
            let backCameraDeviceInput = backCameraDeviceInput,
            let backCameraVideoPort = backCameraDeviceInput.ports(
                for: .video,
                sourceDeviceType: backCamera.deviceType,
                sourceDevicePosition: backCamera.position
            ).first else {
            logger.error("Could not find the back camera device input's video port")
            return false
        }

        guard multiCamSession.canAddOutput(backCameraVideoDataOutput) else {
            logger.error("Cannot add back camera video data output")
            return false
        }

        multiCamSession.addOutput(backCameraVideoDataOutput)
        //        // Check if CVPixelFormat Lossy or Lossless Compression is supported
        //
        //        if backCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
        //            // Set the Lossy format
        //            print("Selecting lossy pixel format")
        //            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
        //        } else if backCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
        //            // Set the Lossless format
        //            print("Selecting a lossless pixel format")
        //            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
        //        } else {
        //            // Set to the fallback format
        //            print("Selecting a 32BGRA pixel format")
        //            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        //        }

        backCameraVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)

        return true
    }

    private func configureFrontCamera() -> Bool {
        multiCamSession.beginConfiguration()
        defer {
            multiCamSession.commitConfiguration()
        }

        // Find front camera
        guard
            let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        else {
            logger.error("Cannot find the front camera")
            return false
        }

        do {
            frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCamera)

            guard
                let frontCameraDeviceInput = frontCameraDeviceInput,
                multiCamSession.canAddInput(frontCameraDeviceInput)
            else {
                logger.error("Cannot add front camera device input")
                return false
            }

            multiCamSession.addInput(frontCameraDeviceInput)
        } catch {
            logger.error("Cannot create front camera device input")
            return false
        }

        // Find front camera device input's video port
        guard
            let frontCameraDeviceInput = frontCameraDeviceInput,
            let frontCameraVideoPort = frontCameraDeviceInput.ports(
                for: .video,
                sourceDeviceType: frontCamera.deviceType,
                sourceDevicePosition: frontCamera.position
            ).first
        else {
            logger.error("Could not find the front camera device input's video port")
            return false
        }

        guard multiCamSession.canAddOutput(frontCameraVideoDataOutput) else {
            print("Could not add the front camera video data output")
            return false
        }

        multiCamSession.addOutput(frontCameraVideoDataOutput)
        //        // Check if CVPixelFormat Lossy or Lossless Compression is supported
        //
        //        if frontCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
        //            // Set the Lossy format
        //            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
        //        } else if frontCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
        //            // Set the Lossless format
        //            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
        //        } else {
        //            // Set to the fallback format
        //            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        //        }

        frontCameraVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)

        return true
    }

    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }

    // user authorization check
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

        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }
        guard let videoDataOutput = output as? AVCaptureVideoDataOutput else { return }
        if videoDataOutput == backCameraVideoDataOutput {
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
