//
//  CameraView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
	@ObservedObject var cameraDataModel: CameraDataModel

	@EnvironmentObject var navigationModel: NavigationModel

	private static let barHeightFactor = 0.15

	var body: some View {
		NavigationStack {
			Group {
				if
					let _ = cameraDataModel.capturedBackCamImage,
					let _ = cameraDataModel.capturedFrontCamImage
				{
					AnalyzeView(cameraDataModel: cameraDataModel)
						.overlayWithSystemImage(systemName: "xmark", alignment: .topTrailing) {
							cameraDataModel.capturedBackCamImage = nil
							cameraDataModel.capturedFrontCamImage = nil
						}
				} else {
					dualCameraCaptureView
				}
			}
			.navigationTitle("Flavor Flash")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar(.hidden, for: .tabBar)
			.statusBarHidden()
		}
	}
}

extension CameraView {
	private var dualCameraCaptureView: some View {
		GeometryReader { geometry in
			ViewfinderView(
				backCamImage: $cameraDataModel.viewfinderBackCamImage,
				frontCamImage: $cameraDataModel.viewfinderFrontCamImage
			)
			.ignoresSafeArea()
			.onAppear(perform: {
				Task {
					await cameraDataModel.camera.start()
					cameraDataModel.capturedBackCamImage = nil
					cameraDataModel.capturedFrontCamImage = nil
				}
			})
			.overlay(alignment: .bottom) {
				Button {
					cameraDataModel.camera.takePhoto()
				} label: {
					ZStack {
						Image(.cameraIcon)
							.resizable()
							.frame(width: 80, height: 80)
						Circle()
							.strokeBorder(.white, lineWidth: 5)
							.frame(width: 80, height: 80)
					}
				}
			}
			.overlayWithSystemImage(systemName: "xmark",alignment: .topTrailing) {
				navigationModel.selectedTab = .home
			}
		}
	}
}

#Preview {
	CameraView(cameraDataModel: CameraDataModel())
}
