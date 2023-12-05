//
//  SecondaryPreviewView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/23.
//

import SwiftUI

struct SecondaryPreviewView: View {

	var previewImage: Image

	var width: CGFloat? = 150

	var height: CGFloat? = 180

    var body: some View {
		previewImage
			.resizable()
			.scaledToFill()
			.frame(width: width, height: height)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.padding(4)
			.background(.black)
			.clipShape(RoundedRectangle(cornerRadius: 10))

    }
}

#Preview {
	SecondaryPreviewView(previewImage: Image(systemName: "pencil"))
}
