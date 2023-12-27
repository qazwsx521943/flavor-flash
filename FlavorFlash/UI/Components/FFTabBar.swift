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
		ZStack(alignment: .bottom) {
			if #available(iOS 17.0, *) {
				TabView(selection: $selectedTab) {

					FoodPrintView()
						.tag(TabItems.foodPrint)
						.tabItem {
							Label("foodPrint", systemImage: "network")
								.foregroundStyle(.white)
						}
						.toolbar(.hidden, for: .tabBar)

					/// no money for google places api
					//				HomeView()
					//					.tag(TabItems.home)
					//					.tabItem {
					//						Label("Home", systemImage: "house.fill")
					//							.foregroundStyle(.white)
					//					}
					//					.toolbar(.hidden, for: .tabBar)

					FlavorFlashView()
						.tag(TabItems.flavorFlash)
						.tabItem {
							Label("Camera", systemImage: "camera")
								.foregroundStyle(.white)
						}
						.toolbar(.hidden, for: .tabBar)
						.onAppear {
							navigationModel.hideTabBar()
						}
						.onDisappear {
							navigationModel.showTabBar()
						}

					LiveStreamView()
						.tag(TabItems.liveStream)
						.tabItem {
							Label("Stream", systemImage: "video.fill")
						}
						.toolbar(.hidden, for: .tabBar)


					ProfileView()
						.tag(TabItems.profile)
						.toolbar(.hidden, for: .tabBar)
				}
				.ignoresSafeArea()
			} else {
				TabView(selection: $selectedTab) {
					ForEach(TabItems.allCases) { tab in
						tab.rootView
							.tag(tab)
							.tabItem {
								Label(tab.title, systemImage: tab.icon)
							}
					}
				}
			}

			if #available(iOS 17.0, *) {
				if !navigationModel.tabBarHidden {
					customTabBar(isDarkMode ? .lightGreen : .darkGreen)
						.ignoresSafeArea()
				}
			}
		}
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

#Preview {
	FFTabBar(selectedTab: .constant(.flavorFlash))
		.environmentObject(NavigationModel())
}
