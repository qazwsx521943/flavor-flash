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

	@State private var isAnimated = false

	var body: some View {
		NavigationStack {
			Group {
				if
					let _ = cameraDataModel.capturedBackCamImage,
					let _ = cameraDataModel.capturedFrontCamImage
				{
					EditorView(cameraDataModel: cameraDataModel)
						.overlayWithSystemImage(systemName: "arrow.left.circle.fill", alignment: .topLeading) {
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
		GeometryReader { _ in
			let animation = Animation.default.repeatCount(2, autoreverses: true)
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
			.onDisappear {
				isAnimated = false
			}
			.overlay(alignment: .bottom) {
				Button {
					withAnimation(animation) {
						isAnimated = true
					}
					cameraDataModel.camera.takePhoto()
				} label: {
					ZStack {
						Image(.cameraIcon)
							.resizable()
							.rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
							.frame(
								width: isAnimated ? 0 : 80,
								height: isAnimated ? 0 : 80
							)

						Circle()
							.strokeBorder(.white, lineWidth: 5)
							.frame(width: 80, height: 80)
					}
				}
			}
			.overlayWithSystemImage(systemName: "xmark", alignment: .topTrailing) {
				navigationModel.selectedTab = .foodPrint
			}
		}
	}
}

#Preview {
	CameraView(cameraDataModel: CameraDataModel())
}
