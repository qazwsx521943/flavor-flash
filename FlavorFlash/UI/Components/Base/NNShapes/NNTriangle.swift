//
//  NNTriangle.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/16.
//

import SwiftUI

struct NNTriangle: Shape {
	func path(in rect: CGRect) -> Path {
		Path { path in
			path.move(to: CGPoint(x: rect.midX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
		}
	}
}

#Preview {
	NNTriangle()
		.frame(width: 300, height: 300)
}
