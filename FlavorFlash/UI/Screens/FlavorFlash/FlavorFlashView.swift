//
//  FlavorFlashView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct FlavorFlashView: View {
	@StateObject private var cameraDataModel = CameraDataModel()

    var body: some View {
        CameraView(cameraDataModel: cameraDataModel)
			.onDisappear(perform: cameraDataModel.camera.stop)
    }
}

#Preview {
    FlavorFlashView()
}
