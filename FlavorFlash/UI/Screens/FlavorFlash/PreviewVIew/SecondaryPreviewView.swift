//
//  SecondaryPreviewView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/23.
//

import SwiftUI

struct SecondaryPreviewView: View {

	var previewImage: Image

    var body: some View {
		previewImage
			.resizable()
			.scaledToFill()
			.frame(width: 150, height: 180)
			.border(.black, width: 4)
			.clipped()
    }
}

#Preview {
	SecondaryPreviewView(previewImage: Image(systemName: "pencil"))
}
