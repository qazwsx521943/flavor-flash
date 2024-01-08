//
//  MockPlaceService.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2024/1/8.
//

import Foundation
import UIKit

class MockPlaceService: PlaceServiceProtocol {
	func fetchPlaceDetailById(id: String) async throws -> Restaurant {
		let mockData = loadJSONFile("searchNearby", resultType: GooglePlaceResult.self)!

		return mockData.places.first!
	}
	
	func fetchNearBy(
		type categories: [String],
		location: Location,
		maxResultCount: Int,
		rankPreference: RankPreference,
		radius: Double,
		completionHandler: @escaping (Result<GooglePlaceResult, Error>) -> Void) {
		guard let mockData = loadJSONFile("searchNearby", resultType: GooglePlaceResult.self) else {
			completionHandler(.failure(fatalError("nearby data error")))
		}

		completionHandler(.success(mockData))
	}
	
	func fetchPlaceByText(keyword: String, location: Location, completionHandler: @escaping (Result<GooglePlaceResult, Error>) -> Void) {

	}
	
	func fetchImage(for id: String, completionHandler: @escaping (UIImage) -> Void) {

	}
}
