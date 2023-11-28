//
//  RestaurantMarkerView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import MapKit

class RestaurantMarkerView: MKMarkerAnnotationView {
	override var annotation: MKAnnotation? {
		willSet {
			guard let restaurant = newValue as? RestaurantAnnotation else {
				return
			}
			canShowCallout = true
			calloutOffset = CGPoint(x: -5, y: 5)

			let mapsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 48, height: 48)))
			mapsButton.setBackgroundImage(#imageLiteral(resourceName: "apple-map"), for: .normal)
			rightCalloutAccessoryView = mapsButton


			markerTintColor = restaurant.markerTintColor
			if let rating = restaurant.rating {
				glyphText = String(describing: rating)
			}
			image = restaurant.image.resizeImageTo(size: CGSize(width: 20, height: 20))!
		}
	}
}
