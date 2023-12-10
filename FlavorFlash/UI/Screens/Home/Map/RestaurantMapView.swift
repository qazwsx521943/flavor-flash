//
//  UIMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import MapKit
import GooglePlaces

struct RestaurantMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    // MARK: - Properties

	@EnvironmentObject var homeViewModel: HomeViewModel

	var currentLocationAnnotation: MKAnnotation {
		guard let currentLocation = homeViewModel.currentLocation else { return MKPointAnnotation() }
		let annotation = MKPointAnnotation()
		annotation.title = "Current"
		annotation.coordinate = currentLocation
		return annotation
	}

    func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()

		// register a custom Annotation as the default reuse identifier, so that we don't have to set up the annotation view via delegate methods.
		mapView.register(
			RestaurantMarkerView.self,
			forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
		)

		mapView.delegate = context.coordinator

		return mapView
	}

	// swiftUI calls this function when state changes
	func updateUIView(_ uiView: MKMapView, context: Context) {
		debugPrint("updated uiview")

		updateRestaurants(mapView: uiView)

		uiView.removeAnnotation(currentLocationAnnotation)
		uiView.addAnnotation(currentLocationAnnotation)

		if let selectedRestaurant = homeViewModel.selectedRestaurant {
			centerToRegion(
				mapView: uiView,
				coordinateRegion: MKCoordinateRegion(
					center: selectedRestaurant.coordinate,
					latitudinalMeters: 200, longitudinalMeters: 200
				)
			)
		} else {
			if let startLocation = homeViewModel.currentLocation {
				debugPrint("start location: \(startLocation)")
				centerToRegion(
					mapView: uiView,
					coordinateRegion: MKCoordinateRegion(
						center: startLocation,
						latitudinalMeters: 200,
						longitudinalMeters: 200
					)
				)
			}
		}
	}

	func makeCoordinator() -> RestaurantMapViewCoordinator {
		RestaurantMapViewCoordinator(self)
	}
}

extension RestaurantMapView {
	func updateRestaurants(mapView: MKMapView) {
		for restaurant in homeViewModel.restaurants {
			let annotation = RestaurantAnnotation(
				title: restaurant.displayName.text,
				rating: restaurant.rating,
				coordinate: restaurant.coordinate
			)

			mapView.addAnnotation(annotation)
        }
    }

	func centerToRegion(mapView: MKMapView, coordinateRegion: MKCoordinateRegion) {
		mapView.setRegion(coordinateRegion, animated: true)
	}
}

//#Preview {
//    RestaurantMapView(restaurants: .constant(RestaurantViewModel(searchCategory: "lunch").restaurants), )
//}
