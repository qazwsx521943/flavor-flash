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
    let map = MKMapView()
    @Binding var restaurants: [Restaurant]
    @State var currentLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        updateRestaurants()
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let currentLocation else { return }
        map.setRegion(MKCoordinateRegion(center: currentLocation, latitudinalMeters: CLLocationDistance(500), longitudinalMeters: CLLocationDistance(500)), animated: true)

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = "目前位置"
        pointAnnotation.coordinate = currentLocation

        map.addAnnotation(pointAnnotation)

//        updateRestaurants()
    }

    func makeCoordinator() -> HomeMapViewCoordinator {
        HomeMapViewCoordinator(mapView: self)
    }
}


extension RestaurantMapView {
    func updateRestaurants() {
        for restaurant in restaurants {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = restaurant.displayName.text
            pointAnnotation.coordinate = restaurant.coordinate
            DispatchQueue.main.async {
                map.addAnnotation(pointAnnotation)
            }
        }
    }
}

#Preview {
    RestaurantMapView(restaurants: .constant(RestaurantViewModel(searchCategory: "lunch").restaurants))
}
