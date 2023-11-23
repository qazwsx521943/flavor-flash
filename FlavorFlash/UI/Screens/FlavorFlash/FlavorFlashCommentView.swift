//
//  FlavorFlashCommentView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct FlavorFlashCommentView: View {
	@ObservedObject var cameraDataModel: CameraDataModel

    var body: some View {
		VStack {
			cameraDataModel.frontCamImage?
				.resizable()
				.frame(width: 100, height: 100)
			cameraDataModel.backCamImage?
				.resizable()
				.frame(width: 100, height: 100)

			TextField("Comment:", text: $cameraDataModel.comment)

			Button {
				Task {
					try await cameraDataModel.saveImages()
				}
			} label: {
				Text("Save!")
					.font(.title3)
					.foregroundStyle(.purple)
			}
		}
    }
}

#Preview {
    FlavorFlashCommentView(cameraDataModel: CameraDataModel())
}
