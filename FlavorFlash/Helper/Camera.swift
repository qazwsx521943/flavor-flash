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
    // single camera session
    private let captureSession = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "capture session queue")
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?

    // MARK: - Capturing Session status
    var isPreviewPaused = false

    private var isCaptureSessionConfigured = false

    var isRunning: Bool {
        captureSession.isRunning
    }

    // capture devices setup
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInDualCamera, .builtInDualWideCamera],
            mediaType: .video,
            position: .front)
        .devices
    }

    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            captureSessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }

    // MARK: - Preview Stream setup
    private var addToPreviewStream: ((CIImage) -> Void)?
    var addToCapturedImage: ((AVCapturePhoto) -> Void)?

    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
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
        captureDevice = allCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
        logger.info("capture device: \(self.captureDevice)")
    }

    // MARK: - Camera Actions
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access is not authorized by user")
            return
        }

        // if capture session is configured, just start the session
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                captureSessionQueue.async {
                    self.captureSession.startRunning()
                }
            }
            return
        }

        // else configure a capture session
        captureSessionQueue.async {
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }

    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }

        captureSessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()

//            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
//                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
//            }
            let availableFormat = kCVPixelFormatType_32BGRA
            photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: availableFormat])

            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            photoSettings.isHighResolutionPhotoEnabled = true
            if 
                let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = 
                [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .balanced

            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported,
                   let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    // MARK: - Capture Session configs
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {

        var success = false

        self.captureSession.beginConfiguration()

        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }

        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error("Failed to obtain video input")
            return
        }

        let photoOutput = AVCapturePhotoOutput()

        // camera resolution config
        captureSession.sessionPreset = .photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))

        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }

        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)

        self.deviceInput = deviceInput
        self.photoOutput = photoOutput

        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality

        // capture session configured
        isCaptureSessionConfigured = true

        success = true
    }

    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }

        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput),
               captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
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

        addToCapturedImage?(photo)
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

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
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

