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

                    } label: {
                        NavigationLink {
                            AnalyzeView(cameraDataModel: cameraDataModel)
                            .task {
                                cameraDataModel.camera.takePhoto()
                            }
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
                }
				.overlay(alignment: .topTrailing) {
					Image(systemName: "xmark")
						.resizable()
						.font(.largeTitle)
						.foregroundStyle(.white)
						.frame(width: 20, height: 20)
						.padding(.trailing, 16)
						.onTapGesture {
							navigationModel.selectedTab = .home
						}
				}
//                .overlay(alignment: .center) {
//                    Color.clear
//                        .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
//                }
//                .background(.black)
            }
            .navigationTitle("Flavor Flash")
            .navigationBarTitleDisplayMode(.inline)
			.toolbar(.hidden, for: .tabBar)
//            .navigationBarHidden(true)
            .statusBarHidden()
        }
    }
}

#Preview {
    CameraView(cameraDataModel: CameraDataModel())
}
