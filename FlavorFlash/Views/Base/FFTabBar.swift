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

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(TabItems.home)

                FlavorFlashView()
                    .tag(TabItems.flavorFlash)

                CommunityView()
                    .tag(TabItems.community)
            }
        }

        ZStack {
            HStack {
                ForEach(TabItems.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        if tab == .flavorFlash {
                            centerTabItem(
                                imageName: tab.icon,
                                title: tab.title,
                                isActive: (selectedTab == tab)
                            )
                        } else {
                            normalTabItem(
                                imageName: tab.icon,
                                title: tab.title,
                                isActive: (selectedTab == tab)
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 60)
        .background(.black.opacity(0.2))
        .cornerRadius(40)
        .padding(.horizontal, 26)
    }
}

extension FFTabBar {
    func centerTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()

            ZStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 80, height: 80)
                Circle()
                    .strokeBorder(.white, lineWidth: 5)
                    .frame(width: 80, height: 80)
            }

            Spacer()
        }
        .frame(width: 80, height: 80)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(40)
    }

    func normalTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()

            Image(imageName)
                .resizable()
                .foregroundColor(isActive ? nil : .gray)
                .frame(width: 60, height: 60)

            Spacer()
        }
        .frame(width: 60, height: 60)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}

#Preview {
    FFTabBar(selectedTab: .constant(.home))
        .environmentObject(NavigationModel())
}
