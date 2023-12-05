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
			VStack {
				if let randomCategoryText = viewModel.category?.title {
					Text(randomCategoryText)
						.font(.title3)
				}

				Image("cube")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(40)
					.onTapGesture {
						viewModel.randomCategory()
					}

				if viewModel.category != nil {
					NavigationLink {
						RestaurantSearchView()
							.environmentObject(viewModel)
					} label: {
						Text("就吃這個！")
							.frame(height: 55)
							.frame(maxWidth: .infinity)
							.frame(alignment: .center)
							.background(animate ? .purple : .red)
							.clipShape(RoundedRectangle(cornerRadius: 10.0))
					}
					.padding(.horizontal, animate ? 30 : 80)
					.foregroundStyle(.white)
					.scaleEffect(animate ? 1.1 : 1.0)
					.offset(y: animate ? -10 : 0)
					.onAppear(perform: addAnimation)
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
	func addAnimation() {
		guard !animate else { return }
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			withAnimation(
				Animation
					.easeInOut(duration: 2)
					.repeatForever()
			) {
				animate.toggle()
			}
		}
	}
}

#Preview {
	HomeView()
}

fileprivate let logger = Logger(subsystem: "flavor-flash.homepage", category: "Home")
