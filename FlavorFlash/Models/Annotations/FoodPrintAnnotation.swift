//
//  FoodPrintAnnotation.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import MapKit

class FoodPrintAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D

	var title: String?

	var subtitle: String?

	var imageUrl: String?

	init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, imageUrl: String? = nil) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
		self.imageUrl = imageUrl
	}

	var markerTintColor: UIColor {
		return .systemPurple
	}

	var glythText: String {
		return "Me"
	}
}
