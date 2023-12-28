//
//  LoginBackground.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/12.
//

import SwiftUI
import Lottie

struct FFLottieView: UIViewRepresentable {
	
	let lottieFile: String
	let animationView = LottieAnimationView()

	func updateUIView(_ uiView: UIView, context: Context) {

	}
	
	func makeUIView(context: Context) -> UIView {
		let view = UIView(frame: .zero)

		animationView.animation = LottieAnimation.named(lottieFile)
		animationView.play()
		animationView.contentMode = .scaleAspectFill
		animationView.backgroundBehavior = .pauseAndRestore
		animationView.loopMode = .loop

		view.addSubview(animationView)

		animationView.translatesAutoresizingMaskIntoConstraints = false

		animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
		animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

		return view
	}
}

#Preview {
	Group {
		FFLottieView(lottieFile: "foodieNation")
			.frame(width: 200, height: 200)

		FFLottieView(lottieFile: "randomFood")
			.frame(width: 200, height: 200)
	}
}
