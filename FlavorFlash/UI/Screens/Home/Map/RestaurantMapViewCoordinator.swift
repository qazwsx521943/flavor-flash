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
	var parent: RestaurantMapView

	let locationManager = CLLocationManager()

	init(_ parent: RestaurantMapView) {
		self.parent = parent
		super.init()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.distanceFilter = kCLDistanceFilterNone
		locationManager.delegate = self
		locationManager.startUpdatingLocation()
	}
}

extension RestaurantMapViewCoordinator: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
		parent.centerToRegion(mapView: mapView, coordinateRegion: MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
	}

//	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//		guard let annotation = annotation as? RestaurantAnnotation else { return nil }
//		
//		var view: MKMarkerAnnotationView
//		if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: RestaurantAnnotation.self)) as? MKMarkerAnnotationView {
//			dequeuedView.annotation = annotation
//			view = dequeuedView
//		} else {
//			view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String(describing: RestaurantAnnotation.self))
//
//			view.canShowCallout = true
//			view.calloutOffset = CGPoint(x: -5, y: 5)
//			view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//		}
//
//		return view
//	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let restaurant = view.annotation as? RestaurantAnnotation else { return }

		let launchOptions = [
			MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
		]

		restaurant.mapItem?.openInMaps(launchOptions: launchOptions)
	}
}

extension RestaurantMapViewCoordinator {
	func fetchNearByRestaurants() {
		guard
			let currentLocation = parent.restaurantViewModel.currentLocation
		else {
			return
		}

		PlaceFetcher.shared.fetchNearBy(type: [parent.restaurantViewModel.category], location: Location(CLLocation: currentLocation)) { [weak self] response in
			switch response {
			case .success(let result):
				self?.parent.restaurantViewModel.restaurants = result.places
			case .failure(let error):
				debugPrint(error.localizedDescription)
			}
		}
	}
}

extension RestaurantMapViewCoordinator: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location: CLLocation = locations.last!
		manager.stopUpdatingLocation()
		debugPrint("locations updated : \(location.coordinate)")
		parent.restaurantViewModel.currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		fetchNearByRestaurants()
	}

	// Handle authorization for the location manager.
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		// Check accuracy authorization
		let accuracy = manager.accuracyAuthorization
		debugPrint("accuracy: \(accuracy)")
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
		manager.stopUpdatingLocation()
		print("Error: \(error)")
	}
}
