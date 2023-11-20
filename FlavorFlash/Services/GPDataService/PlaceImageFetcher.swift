//
//  PlaceImageFetcher.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import Foundation
import GooglePlaces

final class PlaceImageFetcher {
	static let shared = PlaceImageFetcher()

	private let placesClient: GMSPlacesClient

	private init() {
		self.placesClient = GMSPlacesClient()
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
