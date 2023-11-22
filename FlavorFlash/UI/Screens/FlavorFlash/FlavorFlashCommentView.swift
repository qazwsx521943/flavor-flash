//
//  FlavorFlashCommentView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct FlavorFlashCommentView: View {
	@EnvironmentObject private var model: CameraDataModel

    var body: some View {
		VStack {
			model.frontCamImage
				.resizable()
				.frame(width: 100, height: 100)
			model.backCamImage
				.resizable()
				.frame(width: 100, height: 100)

			TextField("Comment:", text: $model.comment)

			Button {
				Task {
					try await model.saveImages()
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
    FlavorFlashCommentView()
}
