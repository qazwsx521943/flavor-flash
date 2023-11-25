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

	var body: some View {
		GeometryReader { geometry in
			VStack {
				if
					let backCamImage = cameraDataModel.backCamImage,
					let frontCamImage = cameraDataModel.frontCamImage {

					ZStack {
						PrimaryPreviewView(previewImage: backCamImage)
							.frame(width: geometry.size.width, height: geometry.size.height - 80)
					}
					.overlay(alignment: .topLeading) {
						SecondaryPreviewView(previewImage: frontCamImage)
					}
					.onAppear(perform: {
						debugPrint("UIDevice.current.orientation \(UIDevice.current.orientation)")
						cameraDataModel.analyzeFood()
						cameraDataModel.camera.stop()
					})

					HStack(alignment: .bottom) {
						NavigationLink {
							FlavorFlashCommentView(cameraDataModel: cameraDataModel)
						} label: {
							Text("Continue ->")
								.font(.title3)
								.foregroundStyle(Color.black)
								.padding()
						}
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 20))
					}
				}
			}
			.navigationTitle("UCCU")
			.toolbarBackground(.visible, for: .navigationBar)
		}
	}
}

fileprivate let logger = Logger(subsystem: "flavor-flash.analyzePhoto", category: "AnalyzePhoto")

//#Preview {
//    FFAnalyzeResult()
//}
