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

	static func getUIImage(urlString: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
		KingfisherManager.shared.retrieveImage(with: URL(string: urlString)!) { result in
			switch result {
			case .success(let result):
				completionHandler(.success(UIImage(cgImage: result.image.cgImage!)))
			case .failure(let error):
				completionHandler(.failure(error))
			}
		}
	}
	
	/// Get's `UIImage` from urlString using async / await
	/// - Parameter urlString: It's a urlString('https://axxxxx'), not URL!
	/// - Returns: UIImage
	static func getUIImage(urlString: String) async throws -> UIImage {
		try await withCheckedThrowingContinuation { continuation in
			Self.getUIImage(urlString: urlString) { result in
				switch result {
				case .success(let image):
					continuation.resume(returning: image)
				case .failure(let error):
					continuation.resume(throwing: error)
				}
			}
		}
	}
}
