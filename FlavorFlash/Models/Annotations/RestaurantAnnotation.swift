//
//  RestaurantAnnotation.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import MapKit
import Contacts

class RestaurantAnnotation: NSObject, MKAnnotation {
	let title: String?
	let rating: CGFloat?
	let coordinate: CLLocationCoordinate2D

	init(
		title: String?,
		rating: CGFloat?,
		coordinate: CLLocationCoordinate2D
	) {
		self.title = title
		self.rating = rating
		self.coordinate = coordinate

		super.init()
	}

	var subtitle: String? {
		guard let rating else { return nil }
		switch rating {
		case _ where rating > 4: return "👍 \(rating)"
		case _ where rating > 3: return "👌 \(rating)"
		case _ where rating < 3: return "👎 \(rating)"
		default:
			return nil
		}
	}

	var mapItem: MKMapItem? {
		guard let title else { return nil }

		let placeMark = MKPlacemark(coordinate: coordinate)
		let mapItem = MKMapItem(placemark: placeMark)
		mapItem.name = title
		return mapItem
	}

	var markerTintColor: UIColor {
		guard let rating else { return .gray }
		switch rating {
		case _ where rating > 4: return .green
		case _ where rating > 3: return .orange
		case _ where rating < 3: return .red
		default: return .gray
		}
	}

	var image: UIImage {
		guard let rating else { return #imageLiteral(resourceName: "flash-dynamic-premium") }
		switch rating {
		case _ where rating > 4: return #imageLiteral(resourceName: "thumb-up-dynamic-color")
		case _ where rating > 3: return #imageLiteral(resourceName: "flash-dynamic-premium")
		case _ where rating < 3: return #imageLiteral(resourceName: "trash-can-dynamic-color")
		default: return #imageLiteral(resourceName: "flash-dynamic-premium")
		}
	}
}
