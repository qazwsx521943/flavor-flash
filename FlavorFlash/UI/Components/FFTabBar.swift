//
//  FFTabBar.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct FFTabBar: View {
	@Binding var selectedTab: TabItems

    @EnvironmentObject private var navigationModel: NavigationModel

	@Environment(\.colorScheme) var colorScheme

	@Namespace private var tabAnimation

    var body: some View {
		TabView(selection: $selectedTab) {
			HomeView()
				.tag(TabItems.home)
				.tabItem {
					Label("Home", systemImage: "house.fill")
						.foregroundStyle(.white)
				}
				.toolbar(.hidden, for: .tabBar)

			FlavorFlashView()
				.tag(TabItems.flavorFlash)
				.tabItem {
					Label("Camera", systemImage: "camera")
						.foregroundStyle(.white)
				}
				.toolbar(.hidden, for: .tabBar)

			FoodPrintView()
				.tag(TabItems.foodPrint)
				.tabItem {
					Label("foodPrint", systemImage: "network")
						.foregroundStyle(.white)
				}
				.toolbar(.hidden, for: .tabBar)

			ProfileView()
				.tag(TabItems.profile)
				.toolbar(.hidden, for: .tabBar)
		}
		.ignoresSafeArea()

		customTabBar(isDarkMode ? .darkOrange : .middleYellow)
    }
}

extension FFTabBar {
	var isDarkMode: Bool {
		colorScheme == .dark
	}

	@ViewBuilder
	func customTabBar(
		_ tint: Color = .middleYellow,
		_ inactiveTint: Color = .shadowGray
	) -> some View {
		HStack(alignment: .bottom, spacing: 10) {
			ForEach(TabItems.allCases) { tabItem in
				TabItem(
					tint: tint,
					inactiveTint: inactiveTint,
					tab: tabItem,
					animation: tabAnimation,
					activeTab: $selectedTab)
			}
		}
		.padding(.horizontal, 15)
		.padding(.vertical, 10)
		.background(
			RoundedRectangle(cornerRadius: 15.0)
				.fill(.shadowGray.opacity(0.4))
				.padding(.top, 20)
				.padding(.horizontal, 10)
		)
		.animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: selectedTab)
	}
}

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
	FFTabBar(selectedTab: .constant(.home))
		.environmentObject(NavigationModel())
}
