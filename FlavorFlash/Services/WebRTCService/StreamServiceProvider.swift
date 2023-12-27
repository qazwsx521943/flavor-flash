//
//  StreamServiceProvider.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/26.
//

import Foundation
import WebRTC

protocol StreamServiceProvider: AnyObject {
	var delegate: StreamServiceProviderDelegate? { get set }
//	func connect()
	func closeStream(id: String)
//	func send(data: Data)
	func createStream(data: Data) async throws -> String
	func joinStream(streamId: String, data: Data) async throws
	func saveCandidate(streamId: String, type: FBCandidateType, data: Data) async throws
}

protocol StreamServiceProviderDelegate: AnyObject {
	func streamServiceDidConnect(_ streamService: StreamServiceProvider)
	func streamServiceDidDisconnect(_ streamService: StreamServiceProvider)
	func streamService(_ streamService: StreamServiceProvider, didReceiveData data: Data)
}
