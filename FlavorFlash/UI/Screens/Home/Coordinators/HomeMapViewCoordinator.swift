//
//  MKMapViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import MapKit
import SwiftUI
import GooglePlaces

class HomeMapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapView: HomeMapView?
    var placeManager = PlaceManager()
//    @Binding var currentLocation: GMSPlaceLikelihood?

    init(mapView: HomeMapView? = nil) {
        super.init()
//        self.currentLocation = currentLocation
        self.mapView = mapView
        placeManager.locationManager.delegate = self
        placeManager.delegate = self
        
    }
}

extension HomeMapViewCoordinator: CLLocationManagerDelegate {

}

extension HomeMapViewCoordinator: PlaceManagerDelegate {
    func placeManager(_ placeManager: PlaceManager, currentLocation: [GMSPlaceLikelihood]) {
        let currentLocation = currentLocation.first
        mapView?.currentLocation = currentLocation?.place.coordinate
    }
}
