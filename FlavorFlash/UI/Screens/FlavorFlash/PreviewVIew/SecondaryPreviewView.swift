//
//  SecondaryPreviewView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/23.
//

import SwiftUI

struct SecondaryPreviewView: View {

	var previewImage: Image

	var width: CGFloat?

	var height: CGFloat?

	@State private var offset: CGSize

	@State private var lastOffset: CGSize

	init(
		previewImage: Image,
		width: CGFloat? = 150,
		height: CGFloat? = 180,
		offset: CGSize = CGSize(width: 48, height: 100)) {
		self.previewImage = previewImage
		self.width = width
		self.height = height
		self._offset = State(wrappedValue: offset)
		self._lastOffset = State(wrappedValue: offset)
	}

    var body: some View {
		previewImage
			.resizable()
			.scaledToFill()
			.frame(width: width, height: height)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.padding(4)
			.background(.black)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.offset(offset)
			.gesture(
				DragGesture()
					.onChanged { value in
						offset = CGSize(
							width: lastOffset.width + value.translation.width,
							height: lastOffset.height + value.translation.height)
					}
					.onEnded { value in
						lastOffset = offset
					}
			)
    }
}

#Preview {
	SecondaryPreviewView(previewImage: Image(systemName: "pencil"))
}
