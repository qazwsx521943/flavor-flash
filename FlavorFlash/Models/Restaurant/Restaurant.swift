//
//  Restaurant.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import SwiftUI
import CoreLocation
import GooglePlaces

// https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places?hl=zh-tw#Place
struct Restaurant: Hashable, Codable, Identifiable {
	let name: String
	let id: String
	let displayName: LocalizedText
	let formattedAddress: String?
	let shortFormattedAddress: String?
	let addressComponents: [AddressComponent]?
	let location: Location
	let rating: CGFloat?
	let photos: [Photo]?

	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(
			latitude: location.latitude,
			longitude: location.longitude
		)
	}

	struct LocalizedText: Codable, Hashable {
		let text: String
		let languageCode: String
	}

	struct AddressComponent: Codable, Hashable {
		let longText: String
		let shortText: String
		let types: [String]
		let languageCode: String
	}

	struct Location: Codable, Hashable {
		let latitude: CGFloat
		let longitude: CGFloat
	}

	struct Photo: Codable, Hashable {
		let name: String
		let widthPx: Int
		let heightPx: Int
	}
}

extension Restaurant {
	func loadMainImage(completionHandler: @escaping (Image) -> Void) {
		guard
			let _ = photos
		else { return }
		let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))

		GMSPlacesClient.shared().fetchPlace(
			fromPlaceID: "INSERT_PLACE_ID_HERE",
			placeFields: fields,
			sessionToken: nil, callback: { (place: GMSPlace?, error: Error?) in
			if let error = error {
				print("An error occurred: \(error.localizedDescription)")
				return
			}
			if let place = place {
				// Get the metadata for the first photo in the place photo metadata list.
				let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

				// Call loadPlacePhoto to display the bitmap and attribution.
				GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
					if let error = error {
						// TODO: Handle the error.
						print("Error loading photo metadata: \(error.localizedDescription)")
						return
					} else {
						completionHandler(Image(uiImage: photo!))
					}
				})
			}
		})
	}
}
