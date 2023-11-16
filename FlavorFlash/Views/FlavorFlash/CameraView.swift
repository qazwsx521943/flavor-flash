//
//  CameraView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var model = CameraDataModel()

    private static let barHeightFactor = 0.15

    var body: some View {
        GeometryReader { geometry in
            ViewfinderView(image: $model.viewfinderImage, capturedImage: $model.capturedImage)
                .overlay(alignment: .top) {
                    Color.black
                        .opacity(0.75)
                        .frame(height: geometry.size.height * Self.barHeightFactor)
                }
                .overlay(alignment: .bottom) {
                    Button {
                        model.camera.takePhoto()
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
                .overlay(alignment: .center) {
                    Color.clear
                        .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                }
                .overlay(alignment: .topTrailing, content: {
                    Button {
                        model.capturedImage = nil
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

#Preview {
    CameraView()
}
