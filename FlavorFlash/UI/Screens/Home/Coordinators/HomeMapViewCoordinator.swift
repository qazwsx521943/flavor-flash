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

class HomeMapViewCoordinator: NSObject {
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

		do {
			let body: [String: Any] = [
				"languageCode": "zh-TW",
				"includedTypes": [mapView?.category],
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

			let headers: [Alamofire.HTTPHeader] = [
				.contentType("application/json"),
				HTTPHeader(name: "X-Goog-FieldMask", value: "*"),
				HTTPHeader(name: "X-Goog-Api-Key", value: "AIzaSyCkUgmyqSq5eWWUb3DgwHc4Xp_3jLKrSMk")
			]
			let request = 
			AF.request("https://places.googleapis.com/v1/places:searchNearby",
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
		} catch {
			print("error")
		}
	}
}

extension HomeMapViewCoordinator: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
		mapView.setRegion(
			MKCoordinateRegion(
				center: annotation.coordinate,
				span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
			), animated: true
		)
	}
}
