//
//  LoadFileHelper.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2024/1/7.
//

import Foundation

public func loadJSONFile<T: Codable>(_ fileName: String, resultType: T.Type) -> T? {
	let file = Bundle.main.url(forResource: fileName, withExtension: "json")
	guard let file else { return nil }
	do {
		let fileData = try Data(contentsOf: file)
		let result = try JSONDecoder().decode(resultType, from: fileData)
		return result
	} catch {
		return nil
	}
}
