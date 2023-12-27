//
//  SignalingClient.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/26.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
	func signalClientDidConnect(_ signalClient: SignalingClient)
	func signalClientDidDisconnect(_ signalClient: SignalingClient)
	func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
	func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {

	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	private let streamService: StreamServiceProvider
	weak var delegate: SignalClientDelegate?

	init(streamService: StreamServiceProvider) {
		self.streamService = streamService
		self.streamService.delegate = self
	}

	func close(_ streamId: String) {
		self.streamService.closeStream(id: streamId)
	}

	func createStream(sdp rtcSdp: RTCSessionDescription, completionHandler: @escaping (String) -> ()) {
		let message = Message.sdp(SessionDescription(from: rtcSdp))
		do {
			let dataMessage = try self.encoder.encode(message)
			Task {
				let streamId = try await self.streamService.createStream(data: dataMessage)
				completionHandler(streamId)
			}
		}
		catch {
			debugPrint("Warning: Could not encode sdp: \(error)")
		}
	}

	func joinStream(id: String, sdp localSdp: RTCSessionDescription) {
		let message = Message.sdp(SessionDescription(from: localSdp))
		do {
			let dataMessage = try self.encoder.encode(message)
			Task {
				try await self.streamService.joinStream(streamId: id, data: dataMessage)
			}
		} catch {

		}
	}

	func addCandidate(id: String, candidate rtcIceCandidate: RTCIceCandidate, isHost: Bool) {
		let message = Message.candidate(IceCandidate(from: rtcIceCandidate))

		do {
			let dataMessage = try self.encoder.encode(message)
			Task {
				try await self.streamService.saveCandidate(streamId: id, type: isHost ? .offerCandidates : .answerCandidates, data: dataMessage)
			}
		}
		catch {
			debugPrint("Warning: Could not encode candidate: \(error)")
		}
	}
}


extension SignalingClient: StreamServiceProviderDelegate {
	func streamServiceDidConnect(_ streamService: StreamServiceProvider) {
		self.delegate?.signalClientDidConnect(self)
	}

	func streamServiceDidDisconnect(_ streamService: StreamServiceProvider) {
		self.delegate?.signalClientDidDisconnect(self)

		// try to reconnect every two seconds
		DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
			debugPrint("Trying to reconnect to signaling server...")
		}
	}

	func streamService(_ streamService: StreamServiceProvider, didReceiveData data: Data) {
		let message: Message
		do {
			message = try self.decoder.decode(Message.self, from: data)
		} catch {
			debugPrint("Warning: Could not decode incoming message: \(error)")
			return
		}

		switch message {
		case .candidate(let iceCandidate):
			self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
		case .sdp(let sessionDescription):
			self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
		}
	}
}
