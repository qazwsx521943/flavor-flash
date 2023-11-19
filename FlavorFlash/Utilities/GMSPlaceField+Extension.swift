//
//  GMSPlaceField+Extension.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import GooglePlaces

/**
 This extension is used as a workaround to enable using GMSPlaceField as if it were an NS_OPTIONS. Doing so
 enables set notation usage to combine multiple GMSPlaceFields.
 
 e.g. let fields: GMSPlaceField = [.name, .phoneNumber]
 */
extension GMSPlaceField: SetAlgebra {
	public init() {
		self.init(rawValue: 0)
	}

	public func contains(_ member: GMSPlaceField) -> Bool {
		return self.isSuperset(of: member)
	}

	public __consuming func union(_ other: __owned GMSPlaceField) -> GMSPlaceField {
		var returnValue = GMSPlaceField(rawValue: self.rawValue)
		returnValue.formUnion(other)
		return returnValue
	}

	public __consuming func intersection(_ other: GMSPlaceField) -> GMSPlaceField {
		var returnValue = GMSPlaceField(rawValue: self.rawValue)
		returnValue.formIntersection(other)
		return returnValue
	}

	public __consuming func symmetricDifference(_ other: __owned GMSPlaceField) -> GMSPlaceField {
		var returnValue = GMSPlaceField(rawValue: self.rawValue)
		returnValue.formSymmetricDifference(other)
		return returnValue
	}

	public mutating func insert(_ newMember: __owned GMSPlaceField) -> (inserted: Bool, memberAfterInsert: GMSPlaceField) {
		let oldMember = self.intersection(newMember)
		let shouldInsert = oldMember != newMember
		let result = (
			inserted: shouldInsert,
			memberAfterInsert: shouldInsert ? newMember : oldMember)
		if shouldInsert {
			self.formUnion(newMember)
		}
		return result
	}

	public mutating func remove(_ member: GMSPlaceField) -> GMSPlaceField? {
		let intersectionElements = intersection(member)
		guard !intersectionElements.isEmpty else {
			return nil
		}

		self.subtract(member)
		return intersectionElements
	}

	public mutating func update(with newMember: __owned GMSPlaceField) -> GMSPlaceField? {
		let result = self.intersection(newMember)
		self.formUnion(newMember)
		return result.isEmpty ? nil : result
	}

	public mutating func formUnion(_ other: __owned GMSPlaceField) {
		self = GMSPlaceField(rawValue: self.rawValue | other.rawValue)
	}

	public mutating func formIntersection(_ other: GMSPlaceField) {
		self = GMSPlaceField(rawValue: self.rawValue & other.rawValue)
	}

	public mutating func formSymmetricDifference(_ other: __owned GMSPlaceField) {
		self = GMSPlaceField(rawValue: self.rawValue ^ other.rawValue)
	}

	public typealias Element = GMSPlaceField

	public typealias ArrayLiteralElement = GMSPlaceField
}

extension GMSPlacesClient {
	func getImage(from metaData: GMSPlacePhotoMetadata, completionHandler: @escaping (UIImage) -> Void) {
		self.loadPlacePhoto(metaData) { image, error in
			if let error {
				print(error)
			}
			guard let image else {
				return
			}
			completionHandler(image)
		}
	}
}
