//
//  FoodPrintMapViewController.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import SwiftUI
import MapKit



struct FoodPrintMapView: UIViewRepresentable {

	@ObservedObject var profileViewModel: ProfileViewModel

	typealias UIViewType = MKMapView

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator

		mapView.register(FoodPrintAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		return mapView
	}

	func updateUIView(_ uiView: UIViewType, context: Context) {
		debugPrint("inside updateView : \(profileViewModel.foodPrints)")
		for foodPrint in profileViewModel.foodPrints {
			if let location = foodPrint.location {
				let coordinate = CLLocationCoordinate2D(location: location)
				let annotation = FoodPrintAnnotation(
					coordinate: coordinate,
					title: foodPrint.id,
					subtitle: foodPrint.restaurantId,
					imageUrl: foodPrint.backCameraImageUrl)
				uiView.addAnnotation(annotation)
			}
		}

		debugPrint("friend foodPrints: \(profileViewModel.friendFoodPrints.map { $0.id })")
		for friendFoodPrint in profileViewModel.friendFoodPrints {
			if let location = friendFoodPrint.location {
				let coordinate = CLLocationCoordinate2D(location: location)
				let annotation = FoodPrintAnnotation(
					coordinate: coordinate,
					title: friendFoodPrint.id,
					subtitle: friendFoodPrint.restaurantId,
					imageUrl: friendFoodPrint.backCameraImageUrl
				)

				uiView.addAnnotation(annotation)
			}
		}

		if !profileViewModel.foodPrints.isEmpty {
			uiView.setRegion(MKCoordinateRegion(
				center: CLLocationCoordinate2D(location: profileViewModel.foodPrints.first!.location!),
				latitudinalMeters: CLLocationDistance(300),
				longitudinalMeters: CLLocationDistance(300)),
				animated: true)
		}
	}

	func makeCoordinator() -> FoodPrintMapViewCoordinator {
		return FoodPrintMapViewCoordinator(self)
	}
}

class FoodPrintMapViewCoordinator: NSObject, MKMapViewDelegate {

	let parentView: FoodPrintMapView

	init(_ parentView: FoodPrintMapView) {
		self.parentView = parentView
	}
}

//#Preview {
//	FoodPrintMapView()
//}
