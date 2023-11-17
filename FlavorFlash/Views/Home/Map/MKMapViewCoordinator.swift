//
//  MKMapViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import MapKit

class MKMapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapView: MKMapView?

    override init() {
        super.init()

    }

    init(mapView: MKMapView? = nil) {
        self.mapView = mapView
    }
}
