//
//  PlaceManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import GooglePlaces
import CoreLocation
import os.log

protocol PlaceManagerDelegate: AnyObject {
    func placeManager(_ placeManager: PlaceManager, currentLocation: [GMSPlaceLikelihood])
}

final class PlaceManager: NSObject {
    // MARK: - Properties
    private var placeLikelihoods: [GMSPlaceLikelihood]?
    private lazy var placeClient: GMSPlacesClient = GMSPlacesClient.shared()
    var locationManager = {
        let manager = CLLocationManager()
        return manager
    }()
    weak var delegate: PlaceManagerDelegate? {
        didSet {
            loadLikelihoodFromCurrentLocation()
        }
    }

    private var authorized: Bool {
        return locationManager.authorizationStatus == .authorizedAlways ||
        locationManager.authorizationStatus == .authorizedWhenInUse
    }

    override init() {
        super.init()
    }

    func loadLikelihoodFromCurrentLocation() {
        DispatchQueue.global().async {
            guard
                CLLocationManager.locationServicesEnabled()
            else {
                DispatchQueue.main.async { [weak self] in
                    self?.locationManager.requestWhenInUseAuthorization()
                }
                return
            }
        }
        guard authorized else { return }
        locationManager.startUpdatingLocation()

        // Note: The OptionSet syntax below is enabled by the GMSPlaceField+SetAlgebra extension.
        // See: GMSPlaceField+SetAlgebra.swift
        let placeFields: GMSPlaceField = [.name, .placeID, .coordinate]

        placeClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (list, error) -> Void in
            guard let strongSelf = self else { return }
            guard error == nil else {
                logger.error("Cannot findPlace likelihoods from current location")
                return
            }

            strongSelf.placeLikelihoods = list?.filter { likelihood in
                !(likelihood.place.name?.isEmpty ?? true)
            }

            strongSelf.delegate?.placeManager(strongSelf, currentLocation: strongSelf.placeLikelihoods ?? [])
        }
    }
}

fileprivate let logger = Logger(subsystem: "flavor-flash.placeManager", category: "Map")
