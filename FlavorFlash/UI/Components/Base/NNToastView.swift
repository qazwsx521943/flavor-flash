//
//  NNToastView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/14.
//

import SwiftUI

struct NNToastView: View {

	let title: String

	let subTitle: String

    var body: some View {
		HStack {
			Image(systemName: "person.fill")

			Text(title)
		}
    }
}

//#Preview {
//    NNToastView()
//}
