//
//  Location.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/23.
//

import Foundation
import CoreLocation

struct Location: Codable, Hashable {
	let latitude: CGFloat
	let longitude: CGFloat
}

extension Location {
	init(CLLocation: CLLocationCoordinate2D) {
		self.latitude = CLLocation.latitude
		self.longitude = CLLocation.longitude
	}
}

extension CLLocationCoordinate2D {
	init(location: Location) {
		self.init()
		latitude = location.latitude
		longitude = location.longitude
	}
}
