//
//  FFAnalyzeResult.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/16.
//

import SwiftUI
import AVFoundation
import os.log

struct EditorView: View {
	@ObservedObject var cameraDataModel: CameraDataModel

	@StateObject var canvasViewModel = CanvasViewModel()

	@State private var isBackImagePrimary = true

	@State private var showPhotoPicker: Bool = false

	@State private var showTextEditor: Bool = false

	var body: some View {

		VStack {
			editingOptions

			if
				let backCamImage = cameraDataModel.backCamImage,
				let frontCamImage = cameraDataModel.frontCamImage {

				CanvasView(backCamImage: backCamImage, frontCamImage: frontCamImage)
				.frame(maxWidth: .infinity)
			}

			if showTextEditor {
				TextEditorView(showEditorView: $showTextEditor) { anyView in
					canvasViewModel.addStackItem(anyView)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.black.opacity(0.6))
			}

			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.sheet(isPresented: $showPhotoPicker) {
			PhotoPickerVC(showPicker: $showPhotoPicker)
		}
		.environmentObject(canvasViewModel)
		.onAppear {
			cameraDataModel.analyzeFood()
			cameraDataModel.camera.stop()
		}
	}
}

extension EditorView {
	private var editingOptions: some View {
		HStack {
			Spacer()

			if #available(iOS 17.0, *) {
				Button {
					showTextEditor.toggle()
				} label: {
					Image(systemName: "textformat")
				}.buttonStyle(IconButtonStyle())

				Button {
					showPhotoPicker.toggle()
				} label: {
					Image(systemName: "photo.fill")

				}.buttonStyle(IconButtonStyle())
			}

			NavigationLink {
				CommentView(cameraDataModel: cameraDataModel)
			} label: {
				Image(systemName: "arrow.right.circle.fill")
					.resizable()
					.frame(width: 40, height: 40)
			}
		}
		.frame(maxWidth: .infinity)
	}
}

fileprivate let logger = Logger(subsystem: "flavor-flash.analyzePhoto", category: "AnalyzePhoto")

//#Preview {
//    FFAnalyzeResult()
//}
