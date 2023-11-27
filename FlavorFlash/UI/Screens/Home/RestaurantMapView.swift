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

	@ObservedObject var restaurantViewModel: RestaurantViewModel

    func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
        mapView.delegate = context.coordinator

		return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
		debugPrint("updated uiview")
		updateRestaurants(mapView: uiView)

        let pointAnnotation = MKPointAnnotation()
		if let currentLocation = restaurantViewModel.currentLocation {
			pointAnnotation.title = "目前位置"
			pointAnnotation.coordinate = currentLocation
		}

        uiView.addAnnotation(pointAnnotation)
		updateRegion(mapView: uiView)
//        updateRestaurants()
    }

    func makeCoordinator() -> RestaurantMapViewCoordinator {
        RestaurantMapViewCoordinator(self)
    }
}

extension RestaurantMapView {
	func updateRestaurants(mapView: MKMapView) {
		for restaurant in restaurantViewModel.restaurants {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = restaurant.displayName.text
            pointAnnotation.coordinate = restaurant.coordinate

            DispatchQueue.main.async {
				mapView.addAnnotation(pointAnnotation)
            }
        }
    }

	func updateRegion(mapView: MKMapView) {
		guard let currentLocation = restaurantViewModel.currentLocation else { return }
        mapView.setRegion(
            MKCoordinateRegion(
				center: currentLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ),
            animated: true)
    }
}

//#Preview {
//    RestaurantMapView(restaurants: .constant(RestaurantViewModel(searchCategory: "lunch").restaurants), )
//}
