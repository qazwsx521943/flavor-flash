//
//  CameraPreviewView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/23.
//

import SwiftUI

struct PrimaryPreviewView: View {

	var previewImage: Image

    var body: some View {
		previewImage
			.resizable()
			.scaledToFill()
			.clipped()
    }
}

#Preview {
	PrimaryPreviewView(previewImage: Image(systemName: "pencil"))
}
