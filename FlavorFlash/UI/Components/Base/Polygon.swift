//
//  Polygon.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/7.
//

import SwiftUI

struct Polygon: Shape {
	var sides : Int = 5

	func path(in rect : CGRect ) -> Path{
		// get the center point and the radius
		let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
		let radius = rect.width / 2

		// get the angle in radian,
		// 2 pi divided by the number of sides
		let angle = Double.pi * 2 / Double(sides)
		var path = Path()
		var startPoint = CGPoint(x: 0, y: 0)

		for side in 0 ..< sides {

			let x = center.x + CGFloat(cos(Double(side) * angle)) * CGFloat(radius)
			let y = center.y + CGFloat(sin(Double(side) * angle)) * CGFloat(radius)

			let vertexPoint = CGPoint( x: x, y: y)

			if (side == 0) {
				startPoint = vertexPoint
				path.move(to: startPoint )
			}
			else {
				path.addLine(to: vertexPoint)
			}

			// move back to starting point
			// needed for stroke
			if ( side == (sides - 1) ){
				path.addLine(to: startPoint)
			}
		}

		return path
	}
}

#Preview {
    Polygon()
}
