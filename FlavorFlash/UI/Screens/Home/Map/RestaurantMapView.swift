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

	@State var centerLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()

		mapView.register(RestaurantMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = context.coordinator

		return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
		debugPrint("updated uiview")
		updateRestaurants(mapView: uiView)

        let pointAnnotation = MKPointAnnotation()
		if let currentLocation = homeViewModel.currentLocation {
			pointAnnotation.title = "目前位置"
			pointAnnotation.coordinate = currentLocation
		}

        uiView.addAnnotation(pointAnnotation)

		if let centerLocation {
			centerToRegion(
				mapView: uiView,
				coordinateRegion: MKCoordinateRegion(center: centerLocation, latitudinalMeters: 200, longitudinalMeters: 200))
		}
    }

    func makeCoordinator() -> RestaurantMapViewCoordinator {
        RestaurantMapViewCoordinator(self)
    }
}

extension RestaurantMapView {
	func updateRestaurants(mapView: MKMapView) {
		for restaurant in homeViewModel.restaurants {
			let annotation =
			RestaurantAnnotation(
				title: restaurant.displayName.text,
				rating: restaurant.rating,
				coordinate: restaurant.coordinate)

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
