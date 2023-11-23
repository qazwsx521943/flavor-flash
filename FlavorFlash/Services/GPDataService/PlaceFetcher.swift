//
//  PlaceImageFetcher.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation
import GooglePlaces
import Alamofire

final class PlaceFetcher {
	static let shared = PlaceFetcher()

	private let placesClient: GMSPlacesClient

	private init() {
		self.placesClient = GMSPlacesClient()
	}

	enum PlaceFetcherError: Error {
		case noPlacesFound
		case responseError
	}

	func listLikelyPlaces(completionHandler: @escaping (Result<[GMSPlaceLikelihood], Error>) -> Void) {
		let placeFields: GMSPlaceField = [.name, .coordinate]

		placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { placeLikelihoods, error in
			if let error {
				completionHandler(.failure(PlaceFetcherError.responseError))
				return
			}

			// Get likely places and add to the list.
			//			for likelihood in placeLikelihoods {
			//				let place = likelihood.place
			//				self.likelyPlaces.append(place)
			//			}
			guard let placeLikelihoods else {
				completionHandler(.failure(PlaceFetcherError.noPlacesFound))
				return
			}

			completionHandler(.success(placeLikelihoods))
		}
	}

	func fetchNearBy(type categories: [String], location: Location, completionHandler: @escaping (Result<GooglePlaceResult, Error>) -> Void) {
			let body: [String: Any] = [
				"languageCode": "zh-TW",
				"includedTypes": categories,
				"maxResultCount": 20,
				"rankPreference": "DISTANCE",
				"locationRestriction": [
					"circle": [
						"center": ["latitude": location.latitude,
								   "longitude": location.longitude],
						"radius": 1000.0
					]
				]
			]

			let headers: [Alamofire.HTTPHeader] = [
				.contentType("application/json"),
				HTTPHeader(name: "X-Goog-FieldMask", value: "*"),
				HTTPHeader(name: "X-Goog-Api-Key", value: "AIzaSyCkUgmyqSq5eWWUb3DgwHc4Xp_3jLKrSMk")
			]
			let request =
			AF.request("https://places.googleapis.com/v1/places:searchNearby",
					   method: .post,
					   parameters: body,
					   encoding: JSONEncoding(options: .prettyPrinted),
					   headers: HTTPHeaders(headers)
			)
			request.responseDecodable(of: GooglePlaceResult.self) { response in
				//				debugPrint(response.debugDescription)
				switch response.result {
				case .success(let result):
					completionHandler(.success(result))
				case .failure(let error):
					completionHandler(.failure(error))
				}
			}
		}

	func fetchPlaceByText(keyword: String, completionHandler: @escaping (Result<GooglePlaceResult, Error>) -> Void) {
		let headers: [Alamofire.HTTPHeader] = [
			.contentType("application/json"),
			HTTPHeader(name: "X-Goog-FieldMask", value: "*"),
			HTTPHeader(name: "X-Goog-Api-Key", value: "AIzaSyCkUgmyqSq5eWWUb3DgwHc4Xp_3jLKrSMk")
		]

		let body: [String: Any] = [
			"textQuery": keyword,
			"includedType": "restaurant",
			"rankPreference": "DISTANCE",
			"maxResultCount": 20,
		]

		let request =
		AF.request("https://places.googleapis.com/v1/places:searchText",
				   method: .post,
				   parameters: body,
				   encoding: JSONEncoding(options: .prettyPrinted),
				   headers: HTTPHeaders(headers)
		)
		request.responseDecodable(of: GooglePlaceResult.self) { response in
			debugPrint(response.debugDescription)
			switch response.result {
			case .success(let result):
				completionHandler(.success(result))
			case .failure(let error):
				completionHandler(.failure(error))
			}
		}
	}

	func fetchImage(for id: String, completionHandler: @escaping (UIImage) -> Void) {
		let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))

		placesClient.fetchPlace(fromPlaceID: id,
								placeFields: fields,
								sessionToken: nil, callback: {
			(place: GMSPlace?, error: Error?) in
			if let error = error {
				print("An error occurred: \(error.localizedDescription)")
				return
			}
			if let place = place {
				// Get the metadata for the first photo in the place photo metadata list.
				let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

				// Call loadPlacePhoto to display the bitmap and attribution.
				self.placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
					if let error = error {
						// TODO: Handle the error.
						print("Error loading photo metadata: \(error.localizedDescription)")
						return
					} else {
						// Display the first image and its attributions.
						guard let photo else { return }
						completionHandler(photo)
					}
				})
			}
		})
	}
}
