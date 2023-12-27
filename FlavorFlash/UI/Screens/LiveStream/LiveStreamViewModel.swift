//
//  LiveStreamViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/25.
//

import Foundation
import SwiftUI
import WebRTC
import OSLog

@MainActor
class LiveStreamViewModel: ObservableObject {
	private let webRTCClient = WebRTCClient()
	private let signalingClient = SignalingClient(streamService: StreamService.shared)

	@Published var streamId: String?

	@Published var streamIds: [String]

	@Published var localPreviewStream: Image?

	@Published var remotePreviewStream: Image?

	var isHost = false

	init(streamId: String? = nil, streamIds: [String] = []) {
		self.streamId = streamId
		self.streamIds = streamIds

		webRTCClient.delegate = self
		signalingClient.delegate = self

		getAllStreamIds()
	}

	public func createStream() {
		isHost = true
		webRTCClient.offer { [weak self] sdp in
			guard let self = self else { return }
			logger.info("create stream sdp type: \(sdp.type.rawValue)")
			self.signalingClient.createStream(sdp: sdp) { id in
				DispatchQueue.main.async {
					self.streamId = id
				}
			}
		}
	}

	public func getAllStreamIds() {
		StreamService.shared.getAllStreamIds { [weak self] id in
			self?.streamIds.append(id)
		}
	}

	public func joinStream(id: String) {
		debugPrint("joining stream")
		isHost = false
		Task {
			let sdp	= try await StreamService.shared.getStreamOffer(id: id)
			guard let sdp else { return }
			webRTCClient.set(remoteSdp: sdp) { [weak self] error in

				self?.webRTCClient.answer { [weak self] sdp in
					guard let self = self else { return }
					Task {
						debugPrint("answered")
						self.signalingClient.joinStream(id: id, sdp: sdp)
					}
				}
			}
		}
	}

	public func buildVideoVC() -> VideoStreamViewController {
		return VideoStreamViewController(webRTCClient: webRTCClient)
	}
}

extension LiveStreamViewModel: WebRTCClientDelegate {
	func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
		guard let streamId = streamIds.first else { return }

		self.signalingClient.addCandidate(id: streamId, candidate: candidate, isHost: isHost)
	}
	
	func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
		if state == .disconnected {
			guard let streamId else { return }
			signalingClient.close(streamId)
		}
	}
	
	func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {

	}
}

extension LiveStreamViewModel: SignalClientDelegate {
	func signalClientDidConnect(_ signalClient: SignalingClient) {

	}
	
	func signalClientDidDisconnect(_ signalClient: SignalingClient) {

	}
	
	func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
		logger.info("remote sdp setted")
		webRTCClient.set(remoteSdp: sdp) { error in
			logger.error("error setting remote sdp")
		}
	}
	
	func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
		logger.info("received remote candidate")
		webRTCClient.set(remoteCandidate: candidate) { error in
			logger.error("error setting remote candidate")
		}
	}
}

fileprivate let logger = Logger(subsystem: "ios22-jason.FlavorFlash", category: "LiveStreamViewModel")
