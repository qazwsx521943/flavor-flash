//
//  UIMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import MapKit

struct HomeMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    // MARK: - Properties
    @Binding var restaurants: [Restaurant]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        map.setRegion(MKCoordinateRegion(center: restaurants[0].coordinate, latitudinalMeters: CLLocationDistance(500), longitudinalMeters: CLLocationDistance(500)), animated: true)
        for restaurant in restaurants {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = restaurant.title
            pointAnnotation.coordinate = restaurant.coordinate

            map.addAnnotation(pointAnnotation)
        }
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

    }

    func makeCoordinator() -> HomeMapViewCoordinator {
        HomeMapViewCoordinator()
    }
}

#Preview {
    HomeMapView(restaurants: .constant(RestaurantViewModel().restaurant))
}
