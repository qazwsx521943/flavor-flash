//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct HomeMapView: View {
    @EnvironmentObject private var navigationModel: NavigationModel

    var body: some View {
        VStack {
            UIMapView()
        }
        .navigationTitle("MAP")
    }
}

#Preview {
    HomeMapView()
        .environmentObject(NavigationModel())
}
