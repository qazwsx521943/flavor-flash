//
//  FFTabBar.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct FFTabBar: View {
    @State var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)

                FlavorFlashView()
                    .tag(1)

                CommunityView()
                    .tag(2)
            }
        }

        ZStack {
            HStack {
                ForEach(TabItems.allCases, id: \.self) { item in
                    Button {
                        selectedTab = item.rawValue
                    } label: {
                        customTabItem(imageName: item.icon, title: item.title, isActive: (selectedTab == item.rawValue))
                    }
                }
            }
            .padding(6)
        }
        .frame(height: 70)
        .background(.gray.opacity(0.2))
        .cornerRadius(35)
        .padding(.horizontal, 26)
    }
}

extension FFTabBar {
    func customTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10){
            Spacer()
            Image(imageName)
                .resizable()
//                .renderingMode(.template)
                .foregroundColor(isActive ? nil : .gray)
                .frame(width: 80, height: 80)
            Spacer()
        }
        .frame(width: isActive ? .infinity : 60, height: 60)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}


#Preview {
    FFTabBar()
}
