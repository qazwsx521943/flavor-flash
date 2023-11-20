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

                Button {
                } label: {
                    NavigationLink {
                        RestaurantSearchView(category: category)
                    } label: {
                        Text("就吃這間！")
                            .padding()
                            .border(.white, width: 2)
                    }
                }
                .background(.gray.opacity(0.8))
                .foregroundStyle(.black)
            }
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

#Preview {
    HomeView()
}

fileprivate let logger = Logger(subsystem: "flavor-flash.homepage", category: "Home")
