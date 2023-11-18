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
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate let logger = Logger(subsystem: "flavor-flash.capturingPhotos", category: "CameraDataModel")

