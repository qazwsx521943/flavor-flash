//
//  TabItem.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/25.
//

import SwiftUI

/// Tab Bar Item
struct TabItem: View {
	let tint: Color

	let inactiveTint: Color

	let tab: TabItems

	let animation: Namespace.ID

	@Binding var activeTab: TabItems

	var isActive: Bool {
		activeTab == tab
	}

	var body: some View {
		VStack {
			Image(systemName: tab.icon)
				.bodyBoldStyle()
				.foregroundStyle(isActive ? .white : tint)
				.frame(
					width: isActive ? 50 : 35,
					height: isActive ? 50 : 35
				)
				.background {
					if isActive {
						Circle()
							.fill(tint.gradient)
							.matchedGeometryEffect(id: "ActiveTab", in: animation)
					}
				}

			Text(tab.title)
				.detailBoldStyle()
				.foregroundStyle(isActive ? tint : inactiveTint)
		}
		.frame(maxWidth: .infinity)
		.contentShape(Rectangle())
		.onTapGesture {
			activeTab = tab
		}
	}
}

#Preview {
	TabItem(tint: .green, inactiveTint: .gray, tab: TabItems.foodPrint, animation: Namespace.init().wrappedValue, activeTab: .constant(TabItems.foodPrint))
}
