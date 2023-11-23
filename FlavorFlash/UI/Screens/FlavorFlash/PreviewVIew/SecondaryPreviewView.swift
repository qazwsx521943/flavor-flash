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
			.border(.black, width: 4)
			.clipped()
    }
}

#Preview {
	SecondaryPreviewView(previewImage: Image(systemName: "pencil"))
}
