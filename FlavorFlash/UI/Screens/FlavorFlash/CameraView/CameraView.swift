//
//  CameraView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraDataModel = CameraDataModel()

    private static let barHeightFactor = 0.15

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(
                    backCamImage: $cameraDataModel.viewfinderBackCamImage,
                    frontCamImage: $cameraDataModel.viewfinderFrontCamImage
                )
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
                .overlay(alignment: .center) {
                    Color.clear
                        .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                }
                .background(.black)
            }
            .task {
                await cameraDataModel.camera.start()
            }
            .navigationTitle("Flavor Flash")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBarHidden()
        }
    }
}

#Preview {
    CameraView()
}
