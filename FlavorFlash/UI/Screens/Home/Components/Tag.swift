//
//  Tag.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

protocol TagItem: Hashable {
	associatedtype Identifier: Hashable
	var title: String { get }

	var id: Identifier { get }
}

struct Tag<T: TagItem>: View {
	let item: T

	var action: (() -> Void)?

    var body: some View {
		Button {
			action?()
		} label: {
			Text(item.title)
				.lineLimit(1)
				.frame(maxWidth: .infinity)
		}
		.padding()
		.foregroundStyle(.primary)
		.background(Color.green.colorInvert())
		.clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
	Tag(item: RestaurantCategory.american)
}
