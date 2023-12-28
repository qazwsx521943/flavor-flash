//
//  FBDataService.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//
import Combine

protocol FBDataService: ObservableObject {
	associatedtype Item: FBModelType

	func getData() -> AnyPublisher<[Item], Error>
	func leaveComment(_ item: Item, userId: String, username: String, userProfileImage: String?, comment: String)
	func likePost(_ item: Item, userId: String)
	func dislikePost(_ item: Item, userId: String)
}

protocol FBModelType: Identifiable, Codable {
	var id: String { get set }
}
