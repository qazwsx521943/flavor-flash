//
//  ContentView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var navigationModel = NavigationModel()

    var body: some View {
        FFTabBar(selectedTab: $navigationModel.selectedTab)
            .environmentObject(navigationModel)
    }
}

#Preview {
    ContentView()
}
