//
//  UIMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import MapKit

struct UIMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    // MARK: - Properties
    let playgroundLocation = CLLocationCoordinate2D(latitude: 25.038418, longitude: 121.532370)

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = "AppWorks School"
        pointAnnotation.coordinate = playgroundLocation

        map.addAnnotation(pointAnnotation)
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

    }

    func makeCoordinator() -> MKMapViewCoordinator {
        MKMapViewCoordinator()
    }
}

#Preview {
    UIMapView()
}
