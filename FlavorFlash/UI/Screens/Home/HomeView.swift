//
//  HomeView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import os.log

struct HomeView: View {
	let matrix = ["steak_house", "pizza_restaurant", "seafood_restaurant", "indian_restaurant", "chinese_restaurant"]

	@State private var category: String = ""

	@State private var animate = false

	var body: some View {
		NavigationStack {
			VStack {
				Text(category)
					.font(.title3)

				Image("cube")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(40)
					.onTapGesture {
						category = matrix.randomElement()!
					}

				if !category.isEmpty {
					NavigationLink {
						RestaurantSearchView(category: category)
					} label: {
						Text("就吃這間！")
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
