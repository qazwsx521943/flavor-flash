//
//  KingfisherWrapper.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import UIKit
import Kingfisher

extension UIImageView {
	func loadImage(urlString: String) {
		self.kf.setImage(with: URL(string: urlString)!)
	}

	static func getUIImage(urlString: String, completionHandler: @escaping (UIImage) -> Void) {
		KingfisherManager.shared.retrieveImage(with: URL(string: urlString)!) { result in
			switch result {
			case .success(let result):
				completionHandler(UIImage(cgImage: result.image.cgImage!))
			case .failure(let error):
				debugPrint("KF error: \(error.localizedDescription)")
			}
		}
	}
}
