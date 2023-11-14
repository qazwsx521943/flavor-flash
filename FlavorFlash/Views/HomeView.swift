//
//  HomeView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image("cube")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(40)
        }
    }
}

#Preview {
    HomeView()
}
