//
//  DateFormatter+Extension.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation

extension DateFormatter {
	static let formatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}()
}
