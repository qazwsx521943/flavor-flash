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

    @Published var viewfinderImage: Image?
    @Published var capturedImage: AVCapturePhoto?

    init() {
        camera.addToCapturedImage = { capturedImage in
            self.capturedImage = capturedImage
        }
        Task {
            await handleCameraPreviews()
        }
    }

    // handle camera previews
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream.map { $0.image }

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
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

