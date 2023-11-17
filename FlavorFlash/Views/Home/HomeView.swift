//
//  HomeView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import os.log

struct HomeView: View {

    var body: some View {
        NavigationStack {
            VStack {
                Image("cube")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(40)

                Button {
                } label: {
                    NavigationLink {
                        HomeMapView()
                    } label: {
                        Text("就吃這間！")
                            .padding()
                            .border(.white, width: 2)
                    }
                }
                .background(.gray.opacity(0.8))
                .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    HomeView()
}

fileprivate let logger = Logger(subsystem: "flavor-flash.homepage", category: "Home")
