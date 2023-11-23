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
			guard
				let mapView = self?.mapView,
				let currentLocation = self?.currentLocation
			else {
				return
			}

			PlaceFetcher.shared.fetchNearBy(type: [mapView.category], location: Location(CLLocation: currentLocation)) { response in
				switch response {
				case .success(let result):
					mapView.restaurants = result.places
					mapView.updateRestaurants()
				case .failure(let error):
					debugPrint(error.localizedDescription)
				}
			}
		}
	}
}

extension RestaurantMapViewCoordinator: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
		currentLocation = annotation.coordinate
	}
}

extension RestaurantMapViewCoordinator {
	// Populate the array with the list of likely places.
	func listLikelyPlaces(completionHandler: @escaping () -> Void) {
		// Clean up from previous sessions.
		PlaceFetcher.shared.listLikelyPlaces(completionHandler: { [weak self] response in

			switch response {
			case .success(let placeLikelihoods):
				guard let mostLikelihood = placeLikelihoods.first else { return }
				self?.currentLocation = mostLikelihood.place.coordinate
				completionHandler()
			case .failure(let error):
				debugPrint(error.localizedDescription)
			}
		})
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
