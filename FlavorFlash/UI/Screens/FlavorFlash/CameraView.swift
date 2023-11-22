//
//  CameraView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var model = CameraDataModel()

    private static let barHeightFactor = 0.15

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(
                    backCamImage: $model.viewfinderBackCamImage,
                    frontCamImage: $model.viewfinderFrontCamImage
                )
				.onAppear(perform: {
					Task {
						await model.camera.start()
					}
				})
                .overlay(alignment: .bottom) {
                    Button {

                    } label: {
                        NavigationLink {
                            FFAnalyzeResult(
                                capturedFrontCamImage: $model.capturedFrontCamImage,
                                capturedBackCamImage: $model.capturedBackCamImage
							) {
								model.camera.stop()
							}
                            .task {
                                model.camera.takePhoto()
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
						.environmentObject(model)
                    }
                }
                .overlay(alignment: .center) {
                    Color.clear
                        .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                }
                .overlay(alignment: .topTrailing, content: {
                    Button {
                        model.capturedBackCamImage = nil
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 5)
                            .frame(width: 50, height: 50)
                    }
                })
                .background(.black)
            }
            .task {
                await model.camera.start()
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
