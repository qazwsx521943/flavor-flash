//
//  VideoStreamViewController.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/27.
//

import SwiftUI
import WebRTC

struct VideoStreamViewController: UIViewControllerRepresentable {
	typealias UIViewControllerType = UIViewController

	private let webRTCClient: WebRTCClient

	init(webRTCClient: WebRTCClient) {
		self.webRTCClient = webRTCClient
	}

	func makeUIViewController(context: Context) -> UIViewController {
		let videoStreamVC = UIViewController()

		var localVideoView = UIView()
		let localRenderer = RTCMTLVideoView(frame: .zero)
		let remoteRenderer = RTCMTLVideoView(frame: videoStreamVC.view.frame)

		localRenderer.videoContentMode = .scaleAspectFill
		remoteRenderer.videoContentMode = .scaleAspectFill

		self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
		self.webRTCClient.renderRemoteVideo(to: remoteRenderer)

		self.embedView(localRenderer, into: localVideoView)
		embedView(remoteRenderer, into: videoStreamVC.view)
		videoStreamVC.view.sendSubviewToBack(remoteRenderer)

		return videoStreamVC
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	class Coordinator {
		let parentVC: VideoStreamViewController

		init(_ parentVC: VideoStreamViewController) {
			self.parentVC = parentVC
		}
	}
}

extension VideoStreamViewController {
	private func embedView(_ view: UIView, into containerView: UIView) {
		containerView.addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
																	options: [],
																	metrics: nil,
																	views: ["view":view]))

		containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
																	options: [],
																	metrics: nil,
																	views: ["view":view]))
		containerView.layoutIfNeeded()
	}
}

//#Preview {
//    VideoStreamViewController(webRTCClient: WebRTCClient(iceServers: ))
//}
