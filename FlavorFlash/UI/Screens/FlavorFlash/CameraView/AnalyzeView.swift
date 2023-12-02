//
//  FFAnalyzeResult.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/16.
//

import SwiftUI
import AVFoundation
import os.log

struct AnalyzeView: View {
	@ObservedObject var cameraDataModel: CameraDataModel

	@State private var isBackImagePrimary = true

	var body: some View {
		GeometryReader { geometry in
			if
				let backCamImage = cameraDataModel.backCamImage,
				let frontCamImage = cameraDataModel.frontCamImage {

				ZStack {
					PrimaryPreviewView(previewImage: isBackImagePrimary ? backCamImage : frontCamImage)
						.frame(width: geometry.size.width, height: geometry.size.height - 80)
				}
				.overlay(alignment: .topLeading) {
					SecondaryPreviewView(previewImage: isBackImagePrimary ? frontCamImage : backCamImage)
						.offset(x: 24, y: 20)
						.onTapGesture {
							isBackImagePrimary.toggle()
						}
				}
				.overlay(alignment: .bottomTrailing) {
					NavigationLink {
						FlavorFlashCommentView(cameraDataModel: cameraDataModel)
					} label: {
						Image(systemName: "arrow.right")
							.font(.title)
							.foregroundStyle(Color.black)
							.padding(24)
							.background(.white)
							.clipShape(Circle())
							.shadow(radius: 10)
					}
				}
				.onAppear(perform: {
					cameraDataModel.analyzeFood()
					cameraDataModel.camera.stop()
				})
			}
		}
	}
}

fileprivate let logger = Logger(subsystem: "flavor-flash.analyzePhoto", category: "AnalyzePhoto")

//#Preview {
//    FFAnalyzeResult()
//}
