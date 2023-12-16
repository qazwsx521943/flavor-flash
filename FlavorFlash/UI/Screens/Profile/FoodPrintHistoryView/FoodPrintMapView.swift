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

	var action: (FBFoodPrint) -> ()

	typealias UIViewType = MKMapView

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator

		mapView.register(
			FoodPrintAnnotationView.self,
			forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
		)

		if !profileViewModel.foodPrints.isEmpty {
			mapView.setRegion(MKCoordinateRegion(
				center: CLLocationCoordinate2D(location: profileViewModel.foodPrints.first!.location!),
				latitudinalMeters: CLLocationDistance(300),
				longitudinalMeters: CLLocationDistance(300)),
							 animated: true)
		}

		return mapView
	}

	func updateUIView(_ uiView: UIViewType, context: Context) {
		let needRemoveAnnotation = uiView.annotations.filter { annotation in
			guard let annotation = annotation as? FoodPrintAnnotation else { return false }
			return !profileViewModel.friendFoodPrints.contains { foodPrint in
				foodPrint == annotation.foodPrint
			}
		}

		uiView.removeAnnotations(needRemoveAnnotation)

		for foodPrint in profileViewModel.foodPrints {
			if let location = foodPrint.location {
				let coordinate = CLLocationCoordinate2D(location: location)
				let annotation = FoodPrintAnnotation(
					id: foodPrint.id,
					coordinate: coordinate,
					glythText: "Me",
					foodPrint: foodPrint,
					title: foodPrint.restaurantName,
					subtitle: foodPrint.description,
					imageUrl: foodPrint.backCameraImageUrl)
				uiView.addAnnotation(annotation)
			}
		}

		debugPrint("inside updateView : \(profileViewModel.friendFoodPrints.count)")
		debugPrint("friend foodPrints: \(profileViewModel.friendFoodPrints.map { $0.id })")
		for friendFoodPrint in profileViewModel.friendFoodPrints {
			if let location = friendFoodPrint.location {
				let coordinate = CLLocationCoordinate2D(location: location)
				let annotation = FoodPrintAnnotation(
					id: friendFoodPrint.id,
					coordinate: coordinate,
					glythText: String(friendFoodPrint.username.prefix(5)),
					foodPrint: friendFoodPrint,
					title: friendFoodPrint.restaurantName,
					subtitle: friendFoodPrint.description,
					imageUrl: friendFoodPrint.backCameraImageUrl
				)

				uiView.addAnnotation(annotation)
			}
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

	func mapView(
		_ mapView: MKMapView,
		annotationView view: MKAnnotationView,
		calloutAccessoryControlTapped control: UIControl) {
			guard let restaurant = view.annotation as? FoodPrintAnnotation else { return }

			switch control.tag {
			case 0:
				print("post button")
				parentView.action(restaurant.foodPrint)
			case 1:

				let launchOptions = [
					MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
				]

				restaurant.mapItem?.openInMaps(launchOptions: launchOptions)
			default:
				print("default show post")
			}
	}
}

//#Preview {
//	FoodPrintMapView()
//}
