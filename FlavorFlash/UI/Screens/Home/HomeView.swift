//
//  HomeView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import os.log

struct HomeView: View {
	@StateObject private var viewModel = HomeViewModel()

	@State private var animate = false

	var body: some View {
		NavigationStack {
			let animation = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
			VStack {
				if let randomCategoryText = viewModel.category?.title {
					Text(randomCategoryText)
						.font(.title3)
				}

				Image("cube")
					.resizable()
					.frame(
						width: 150, height: 150
					)
					.onTapGesture {
						viewModel.randomCategory()
						withAnimation(animation) {
							animate = true
						}
					}

				if viewModel.category != nil {
					NavigationLink {
						RestaurantSearchView()
							.environmentObject(viewModel)
					} label: {
						Text("就吃這個！")
							.frame(height: 55)
							.frame(width: 200)
							.background(.black.opacity(0.7))
							.clipShape(RoundedRectangle(cornerRadius: 10.0))
							.shadow(color: Color.white.opacity(0.7), radius: animate ? 10 : 0)
					}
					.foregroundStyle(.white)
				}
			}
			.padding(8)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					NavigationLink {
						ProfileView()
					} label: {
						Image(systemName: "person.fill")
							.foregroundStyle(.white)
					}
				}
			}
			.navigationTitle("要吃什麼？")
		}
	}
}

extension HomeView {
}

#Preview {
	HomeView()
}

fileprivate let logger = Logger(subsystem: "flavor-flash.homepage", category: "Home")
