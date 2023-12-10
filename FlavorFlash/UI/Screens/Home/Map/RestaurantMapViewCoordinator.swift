//
//  MKMapViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import MapKit
import SwiftUI
import GooglePlaces

@MainActor
class RestaurantMapViewCoordinator: NSObject {
	var parent: RestaurantMapView

	let locationManager = CLLocationManager()

	var pendingWorkItem: DispatchWorkItem?

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
		parent.homeViewModel.selectedRestaurant = parent
			.homeViewModel
			.restaurants
			.first { $0.displayName.text == annotation.title }
	}

	// Opens apple map when callout AccessoryControl is tapped
	func mapView(
		_ mapView: MKMapView,
		annotationView view: MKAnnotationView,
		calloutAccessoryControlTapped control: UIControl) {
		guard let restaurant = view.annotation as? RestaurantAnnotation else { return }

		let launchOptions = [
			MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
		]

		restaurant.mapItem?.openInMaps(launchOptions: launchOptions)
	}

//	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//		pendingWorkItem?.cancel()
//
//		let workItem = DispatchWorkItem { [weak self] in
//			let centerCoordinate = mapView.centerCoordinate
//			self?.parent.centerLocation = centerCoordinate
//			self?.fetchNearByRestaurants(centerCoordinate: centerCoordinate)
//		}
//
//		pendingWorkItem = workItem
//		DispatchQueue.global().asyncAfter(deadline: .now() + 2.0, execute: workItem)
//	}
}

extension RestaurantMapViewCoordinator {

	func fetchNearByRestaurants(centerCoordinate: CLLocationCoordinate2D) {

		guard let categoryTag = parent.homeViewModel.category?.searchTag else { return }

		PlaceFetcher.shared.fetchNearBy(
			type: [categoryTag],
			location: Location(CLLocation: centerCoordinate),
			maxResultCount: Int(parent.homeViewModel.maxResultCount ?? 20),
			rankPreference: parent.homeViewModel.rankPreference ?? .distance,
			radius: parent.homeViewModel.searchRadius ?? 1000
		) { [weak self] response in

			switch response {
			case .success(let result):
				debugPrint("nearby search Result: \(result.places.count)")
				self?.parent.homeViewModel.restaurants = result.places

			case .failure(let error):
				debugPrint(error.localizedDescription)
			}
		}
	}
}

// MARK: - CLLocationManager Delegate
extension RestaurantMapViewCoordinator: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location: CLLocation = locations.last!
		manager.stopUpdatingLocation()
		debugPrint("locations updated : \(location.coordinate)")
		parent.homeViewModel.currentLocation = CLLocationCoordinate2D(
			latitude: location.coordinate.latitude,
			longitude: location.coordinate.longitude)

		guard
			let currentLocation = parent.homeViewModel.currentLocation
		else {
			return
		}

		fetchNearByRestaurants(centerCoordinate: currentLocation)
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
