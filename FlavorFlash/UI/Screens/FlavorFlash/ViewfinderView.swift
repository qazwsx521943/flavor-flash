//
//  ViewfinderView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct ViewfinderView: View {
    @Binding var backCamImage: Image?
    @Binding var frontCamImage: Image?

    var body: some View {
        GeometryReader { geometry in
            if let backCamImage, let frontCamImage {
                ZStack {
                    backCamImage
                        .resizable()
                        .scaledToFill()
                }
                .overlay(alignment: .topLeading, content: {
                    frontCamImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 200)
                })
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    ViewfinderView(
        backCamImage: .constant(Image(systemName: "pencil")),
        frontCamImage: .constant(Image(systemName: "pencil")))
}
