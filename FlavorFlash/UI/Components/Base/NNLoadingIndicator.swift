//
//  NNLoadingIndicator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/16.
//

import SwiftUI

struct NNLoadingIndicator: View {

	@State private var animate: Bool = false

    var body: some View {
		return VStack(spacing: 3) {
			NNTriangle()
				.frame(width: 30, height: 20)
				.foregroundStyle(animate ? .lightGreen : .darkGreen)
				.animation(Animation.default.repeatForever().delay(0.2), value: animate)

			Capsule()
				.frame(width: 60, height: 30)
				.foregroundStyle(animate ? .lightGreen : .darkGreen)
				.animation(Animation.default.repeatForever().delay(0.15), value: animate)

			Capsule()
				.frame(width: 80, height: 30)
				.foregroundStyle(animate ? .lightGreen : .darkGreen)
				.animation(Animation.default.repeatForever().delay(0.1), value: animate)

			Capsule()
				.frame(width: 100, height: 30)
				.foregroundStyle(animate ? .lightGreen : .darkGreen)
				.animation(Animation.default.repeatForever().delay(0.05), value: animate)
		}
		.onAppear {
			withAnimation(.default) {
				animate.toggle()
			}
		}
    }
}

#Preview {
    NNLoadingIndicator()
		.frame(width: 200, height: 200)
}
