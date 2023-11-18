//
//  MKMapViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import MapKit
import SwiftUI
import GooglePlaces
import Alamofire

class HomeMapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapView: RestaurantMapView?
    var placeManager = PlaceManager()
    var currentLocation: CLLocationCoordinate2D?

    init(mapView: RestaurantMapView? = nil) {
        super.init()
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
        self.currentLocation = currentLocation?.place.coordinate

        //        let jsonEncoder = JSONEncoder()
        do {
            let body: [String: Any] = [
                "languageCode": "zh-TW",
                "includedTypes": ["restaurant"],
                "maxResultCount": 10,
                "rankPreference": "DISTANCE",
                "locationRestriction": [
                    "circle": [
                        "center": ["latitude": self.currentLocation?.latitude,
                                   "longitude": self.currentLocation?.longitude],
                        "radius": 10000.0
                    ]
                ]
            ]

            let encodedBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            print(String(data: encodedBody, encoding: .utf8))

            let headers: [Alamofire.HTTPHeader] = [
                .contentType("application/json"),
                HTTPHeader(name: "X-Goog-FieldMask", value: "*"),
                HTTPHeader(name: "X-Goog-Api-Key", value: "AIzaSyCkUgmyqSq5eWWUb3DgwHc4Xp_3jLKrSMk")
            ]
            let request = AF.request("https://places.googleapis.com/v1/places:searchNearby",
                                     method: .post,
                                     parameters: body,
                                     encoding: JSONEncoding(options: .prettyPrinted),
                                     headers: HTTPHeaders(headers)
            )
            request.responseDecodable(of: GooglePlaceResult.self) { [weak self] response in
                switch response.result {
                case .success(let result):
                    self?.mapView?.restaurants = result.places
                    self?.mapView?.updateRestaurants()

                case .failure(let error):
                    print("Failed fetching restaurants: \(error.localizedDescription)")
                }
            }
//            request.response { response in
//                switch response.result {
//                case .success(let data):
//                    guard let data else { return }
//
//                    print(String(data: data, encoding: .utf8))
//                case .failure(let error):
//                    print("error fetching nearby parks: \(error.localizedDescription)")
//                }
//            }
        } catch {
            print("error")
        }
    }
}
