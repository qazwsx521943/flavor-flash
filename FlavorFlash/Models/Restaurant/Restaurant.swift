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
	let rating: CGFloat
	let userRatingCount: Int?
	let servesBrunch: Bool?
	let servesLunch: Bool?
	let servesDinner: Bool?
	let regularOpeningHours: RegularOpeningHours?
	let photos: [Photo]?

	// MARK: - Convenient Getters

	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(
			latitude: location.latitude,
			longitude: location.longitude
		)
	}

	var roundedRating: String {
		rating.roundedToString(decimalPlaces: 1)
	}

	var status: String {
		guard let opening = regularOpeningHours?.openNow else { return "Closed" }
		return opening ? "Opening" : "Closed"
	}

	var opening: Bool {
		return regularOpeningHours?.openNow ?? false
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

	struct Photo: Codable, Hashable {
		let name: String
		let widthPx: Int
		let heightPx: Int
	}

	struct RegularOpeningHours: Codable, Hashable {
		let openNow: Bool
		let weekdayDescriptions: [String]
	}
}

extension Restaurant {
	static let mockData = Restaurant(
		name: "places/ChIJr870Oh2qQjQRxyIOR-0GV_U",
		id: "ChIJr870Oh2qQjQRxyIOR-0GV_U",
		displayName: LocalizedText(text: "達美樂披薩 景美興隆店", languageCode: "zh-TW"),
		formattedAddress: "116台灣台北市文山區興隆路一段233號",
		shortFormattedAddress: "興隆路一段233號",
		addressComponents: nil,
		location: Location(latitude: 24.999928, longitude: 121.543962),
		rating: 3.8,
		userRatingCount: 900,
		servesBrunch: true,
		servesLunch: true,
		servesDinner: true, regularOpeningHours: RegularOpeningHours(openNow: true, weekdayDescriptions: [
		"星期一: 11:00 – 22:00",
		"星期二: 11:00 – 22:00",
		"星期三: 11:00 – 22:00",
		"星期四: 11:00 – 22:00",
		"星期五: 11:00 – 23:00",
		"星期六: 11:00 – 23:00",
		"星期日: 11:00 – 22:00"
		]), photos: nil)
}
