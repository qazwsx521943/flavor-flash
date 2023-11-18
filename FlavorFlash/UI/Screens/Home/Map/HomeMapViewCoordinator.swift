//
//  MKMapViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import MapKit
import GooglePlaces

class HomeMapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapView: MKMapView?

    init(mapView: MKMapView? = nil) {
        self.mapView = mapView
    }

}
