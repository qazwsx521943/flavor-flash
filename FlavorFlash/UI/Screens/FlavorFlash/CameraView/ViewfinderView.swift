//
//  ViewfinderView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct ViewfinderView: View {
    @Binding var backCamImage: Image?

    @Binding var frontCamImage: Image?

	@State var isBackCamPrimary = true

    var body: some View {
        GeometryReader { geometry in
            if let backCamImage, let frontCamImage {
                ZStack {
					PrimaryPreviewView(previewImage: isBackCamPrimary ? backCamImage : frontCamImage)
                }
                .overlay(alignment: .bottomTrailing) {
					SecondaryPreviewView(previewImage: isBackCamPrimary ? frontCamImage : backCamImage)
						.onTapGesture {
							isBackCamPrimary.toggle()
						}
                }
                .frame(
					width: geometry.size.width,
					height: geometry.size.height
				)
            }
        }
    }
}

#Preview {
    ViewfinderView(
        backCamImage: .constant(Image(systemName: "pencil")),
        frontCamImage: .constant(Image(systemName: "pencil")))
}
