//
//  NNDiamond.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/16.
//

import SwiftUI

struct NNDiamond: Shape {
	func path(in rect: CGRect) -> Path {
		Path { path in
			let horizontalPadding = rect.width * 0.25

			path.move(to: CGPoint(x: rect.midX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.maxX - horizontalPadding, y: rect.midY))
			path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.minX + horizontalPadding, y: rect.midY))
			path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
		}
	}
}

#Preview {
    NNDiamond()
		.frame(width:300, height:300)
}
