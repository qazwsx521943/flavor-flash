//
//  CGFloat+EXT.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/7.
//

import Foundation
import CoreGraphics

extension CGFloat {
	func roundedToString(decimalPlaces: Int) -> String {
		let formatter = NumberFormatter()
		formatter.minimumFractionDigits = decimalPlaces
		formatter.maximumFractionDigits = decimalPlaces
		return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
	}
}
