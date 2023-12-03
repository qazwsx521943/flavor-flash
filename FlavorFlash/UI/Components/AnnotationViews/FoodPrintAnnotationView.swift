//
//  FoodPrintAnnotationView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import MapKit

class FoodPrintAnnotationView: MKMarkerAnnotationView {
	override var annotation: MKAnnotation? {
		willSet {
			guard let annotation = newValue as? FoodPrintAnnotation else { return }
			canShowCallout = true
			calloutOffset = CGPoint(x: -5, y: 5)

			markerTintColor = annotation.markerTintColor

			let mapsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 48, height: 48)))
			mapsButton.setBackgroundImage(#imageLiteral(resourceName: "apple-map"), for: .normal)
			rightCalloutAccessoryView = mapsButton

			glyphText = annotation.glythText
		}
	}
}
