//
//  FFAnalyzeResult.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/16.
//

import SwiftUI
import AVFoundation
import os.log
import CoreML
import Vision

struct AnalyzeView: View {
    @Binding var capturedFrontCamImage: AVCapturePhoto?
    @Binding var capturedBackCamImage: AVCapturePhoto?
    @State private var result: String = ""
    @State private var classificationRequest: VNCoreMLRequest?
	var stopCamera: (() -> Void)?

    var mobileNetV2 = {
        do {
            let config = MLModelConfiguration()
            return try MobileNetV2(configuration: config)
        } catch let error {
            fatalError("something wrong loading model: \(error.localizedDescription)")
        }
    }()

    var body: some View {
        GeometryReader { geometry in
            if let capturedFrontCamImage, let capturedBackCamImage {
                VStack {
                    ZStack {
                        Image(
                            capturedBackCamImage.cgImageRepresentation()!,
                            scale: 1,
                            orientation: .right,
                            label: Text("large")
                        )
                        .resizable()
                        .scaledToFit()
						.frame(width: geometry.size.width, height: geometry.size.height - 100)
                        .aspectRatio(contentMode: .fill)
                    }
                    .overlay(alignment: .topLeading) {
                        Image(
                            capturedFrontCamImage.cgImageRepresentation()!,
                            scale: 1,
                            orientation: .right,
                            label: Text("small")
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 150)
                        .border(Color.black, width: 4)
                    }

					HStack {
						NavigationLink {
							FlavorFlashCommentView()
						} label: {
							Text("繼續")
								.font(.subheadline)
								.foregroundStyle(.green)
						}
					}
                }
                .overlay(alignment: .center) {
                    Button {
                        analyzePhoto()
						stopCamera?()
                    } label: {
                        Text("Analyze")
                    }
                    .frame(width: 80, height: 80)
                    .background(.blue)
                }
                .navigationTitle(result)
            }
        }
    }

    func processObservations(
        for request: VNRequest,
        error: Error?) {
            // 1
            DispatchQueue.main.async {
                // 2
                if let results = request.results
                    as? [VNClassificationObservation] {
                    // 3
                    if results.isEmpty {
                        result = "nothing found"
                    } else {
                        result = String(
                            format: "%@ %.1f%%",
                            results[0].identifier,
                            results[0].confidence * 100)
                    }
                    // 4
                } else if let error = error {
                    result =
                    "error: \(error.localizedDescription)"
                } else {
                    result = "???"
                }
            }
        }

    private func analyzePhoto() {

        do {
            let VNModel = try VNCoreMLModel(for: mobileNetV2.model)
            let request = VNCoreMLRequest(model: VNModel) { request, error in
                processObservations(for: request, error: error)
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
}

fileprivate let logger = Logger(subsystem: "flavor-flash.analyzePhoto", category: "AnalyzePhoto")

//#Preview {
//    FFAnalyzeResult()
//}
