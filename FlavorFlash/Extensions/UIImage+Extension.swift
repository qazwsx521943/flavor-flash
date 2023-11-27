//
//  UIImage+Extension.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import Foundation
import UIKit

extension UIImage {
	func resizeImageTo(size: CGSize) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		self.draw(in: CGRect(origin: CGPoint.zero, size: size))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return resizedImage
	}
}
