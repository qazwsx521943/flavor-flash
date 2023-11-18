//
//  UIMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import MapKit
import GooglePlaces

struct HomeMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    let map = MKMapView()
    // MARK: - Properties
    @Binding var restaurants: [Restaurant]
    @State var currentLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
//        let map = MKMapView()
//        if let currentLocation {
//            map.setRegion(MKCoordinateRegion(center: currentLocation, latitudinalMeters: CLLocationDistance(500), longitudinalMeters: CLLocationDistance(500)), animated: true)
//        }
        for restaurant in restaurants {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = restaurant.title
            pointAnnotation.coordinate = restaurant.coordinate

            map.addAnnotation(pointAnnotation)
        }
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        guard let currentLocation else { return }
        map.setRegion(MKCoordinateRegion(center: currentLocation, latitudinalMeters: CLLocationDistance(500), longitudinalMeters: CLLocationDistance(500)), animated: true)

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = "目前位置"
        pointAnnotation.coordinate = currentLocation

        map.addAnnotation(pointAnnotation)
    }

    func makeCoordinator() -> HomeMapViewCoordinator {
        HomeMapViewCoordinator(mapView: self)
    }
}

#Preview {
    HomeMapView(restaurants: .constant(RestaurantViewModel().restaurant))
}
