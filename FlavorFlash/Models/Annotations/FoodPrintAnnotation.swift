//
//  FoodPrintAnnotation.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import MapKit

class FoodPrintAnnotation: NSObject, MKAnnotation {
	var id: String

	var foodPrint: FBFoodPrint

	var coordinate: CLLocationCoordinate2D

	var glythText: String

	var title: String?

	var subtitle: String?

	var imageUrl: String?


	init(
		id: String,
		coordinate: CLLocationCoordinate2D,
		glythText: String,
		foodPrint: FBFoodPrint,
		title: String? = nil,
		subtitle: String? = nil,
		imageUrl: String? = nil) {
		self.id = id
		self.coordinate = coordinate
		self.glythText = glythText
		self.foodPrint = foodPrint
		self.title = title
		self.subtitle = subtitle
		self.imageUrl = imageUrl
	}

	var markerTintColor: UIColor {
		switch glythText {
		case "Me": return UIColor.red
		default: return UIColor.purple
		}
	}

	var mapItem: MKMapItem? {
		guard let title else { return nil }

		let placeMark = MKPlacemark(coordinate: coordinate)
		let mapItem = MKMapItem(placemark: placeMark)
		mapItem.name = title
		return mapItem
	}
}
