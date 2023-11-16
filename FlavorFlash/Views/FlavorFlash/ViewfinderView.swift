//
//  ViewfinderView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import AVFoundation

struct ViewfinderView: View {
    @Binding var image: Image?
    @Binding var capturedImage: AVCapturePhoto?

    var body: some View {
        GeometryReader { geometry in
            if let capturedImage {
                Image(
                    capturedImage.cgImageRepresentation()!,
                    scale: 1,
                    orientation: .right,
                    label: Text("cool")
                )
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
            } else if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

//#Preview {
//    ViewfinderView(image: .constant(Image(systemName: "pencil")), capturedImage: <#T##Binding<AVCapturePhoto?>#>)
//}
