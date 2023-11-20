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

class RestaurantMapViewCoordinator: NSObject {
	var mapView: RestaurantMapView?

//	var placeManager = PlaceManager()
	let locationManager = CLLocationManager()

	let placesClient = GMSPlacesClient.shared()

	var currentLocation: CLLocationCoordinate2D? {
		didSet {
			self.mapView?.currentLocation = currentLocation
		}
	}

	init(mapView: RestaurantMapView? = nil) {
		super.init()
		self.mapView = mapView
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.distanceFilter = 50
		locationManager.startUpdatingLocation()
		locationManager.delegate = self

		listLikelyPlaces { [weak self] in
			self?.findNearbyRestaurants()
		}
	}
}

extension RestaurantMapViewCoordinator: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location: CLLocation = locations.last!
		print(location)
	}

	// Handle authorization for the location manager.
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		// Check accuracy authorization
		let accuracy = manager.accuracyAuthorization
		switch accuracy {
		case .fullAccuracy:
			print("Location accuracy is precise.")
		case .reducedAccuracy:
			print("Location accuracy is not precise.")
		@unknown default:
			fatalError()
		}

		// Handle authorization status
		switch status {
		case .restricted:
			print("Location access was restricted.")
		case .denied:
			print("User denied access to location.")
			// Display the map using the default location.
		case .notDetermined:
			print("Location status not determined.")
		case .authorizedAlways: fallthrough
		case .authorizedWhenInUse:
			print("Location status is OK.")
		@unknown default:
			fatalError()
		}
	}

	// Handle location manager errors.
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		locationManager.stopUpdatingLocation()
		print("Error: \(error)")
	}
}

extension RestaurantMapViewCoordinator {
	// Populate the array with the list of likely places.
	func listLikelyPlaces(completionHandler: @escaping () -> Void) {
		// Clean up from previous sessions.

		let placeFields: GMSPlaceField = [.name, .coordinate]
		placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
			guard error == nil else {
				// TODO: Handle the error.
				print("Current Place error: \(error!.localizedDescription)")
				return
			}

			guard let placeLikelihoods = placeLikelihoods else {
				print("No places found.")
				return
			}

			// Get likely places and add to the list.
			//			for likelihood in placeLikelihoods {
			//				let place = likelihood.place
			//				self.likelyPlaces.append(place)
			//			}

			guard let mostLikelihood = placeLikelihoods.first else { return }
			self?.currentLocation = mostLikelihood.place.coordinate
			completionHandler()
		}
	}

	func findNearbyRestaurants() {
		do {
			let body: [String: Any] = [
				"languageCode": "zh-TW",
				"includedTypes": [mapView?.category],
				"maxResultCount": 20,
				"rankPreference": "DISTANCE",
				"locationRestriction": [
					"circle": [
						"center": ["latitude": self.currentLocation?.latitude,
								   "longitude": self.currentLocation?.longitude],
						"radius": 1000.0
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
//				debugPrint(response.debugDescription)
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

extension RestaurantMapViewCoordinator: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
		currentLocation = annotation.coordinate
	}
}
