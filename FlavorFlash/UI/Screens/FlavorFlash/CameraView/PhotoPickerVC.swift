//
//  PhotoPickerVC.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI
import PhotosUI

struct PhotoPickerVC: UIViewControllerRepresentable {

	@EnvironmentObject var canvasViewModel: CanvasViewModel

	@Binding var showPicker: Bool

	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.selectionLimit = 1
		let pickerVC = PHPickerViewController(configuration: config)
		pickerVC.delegate = context.coordinator
		return pickerVC
	}

	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

	}

	func makeCoordinator() -> PhotoPickerCoordinator {
		PhotoPickerCoordinator(self)
	}


	class PhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {


		let parent: PhotoPickerVC

		init(_ parent: PhotoPickerVC) {
			self.parent = parent
		}

		func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

			guard let photo = results.first?.itemProvider else {
				parent.showPicker.toggle()
				return
			}

			photo.loadTransferable(type: Data.self) { result in
				DispatchQueue.main.async { [weak self] in
					switch result {
					case .success(let data):
						self?.parent.canvasViewModel.addStackItem(UIImage(data: data)!)
					case .failure(let error):
						debugPrint("error : \(error)")
					}
				}
			}

			parent.showPicker.toggle()
		}
	}
}

//#Preview {
//	PhotoPickerVC()
//}
