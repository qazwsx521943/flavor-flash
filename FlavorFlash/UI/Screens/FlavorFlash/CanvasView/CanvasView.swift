//
//  CanvasView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

struct CanvasView: View {
	let backCamImage: Image

	let frontCamImage: Image

	@State private var isBackImagePrimary: Bool = true

	@EnvironmentObject var canvasViewModel: CanvasViewModel

    var body: some View {
		ZStack {
			PrimaryPreviewView(previewImage: isBackImagePrimary ? backCamImage : frontCamImage)
				.scaledToFit()
				.frame(maxWidth: .infinity)

			if #available(iOS 17.0, *) {
				ForEach($canvasViewModel.stack) { $stackItem in
					CanvasStackItem(stackItem: $stackItem) {
						stackItem.view
					} moveFront: {
						canvasViewModel.moveToFront(stackItem)
					} delete: {
						canvasViewModel.deleteStackItem(stackItem)
					}
				}
			}
		}
		.overlay(alignment: .topLeading) {
			SecondaryPreviewView(previewImage: isBackImagePrimary ? frontCamImage : backCamImage, offset: CGSize(width: 12, height: 10))
				.onTapGesture {
					isBackImagePrimary.toggle()
				}
		}
    }
}

//#Preview {
//    CanvasView()
//}
