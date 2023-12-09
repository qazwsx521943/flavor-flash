//
//  NavigationBarBackButton.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/9.
//

import SwiftUI

struct NavigationBarBackButton: ToolbarContent {

	@Environment(\.presentationMode) var presentationMode

	@Environment(\.colorScheme) var colorScheme

	var body: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button { presentationMode.wrappedValue.dismiss() } label: {
				Image(systemName: "arrowtriangle.left.fill")
					.foregroundColor(colorScheme == .light ? Color.black : .white)
					.bodyBoldStyle()
			}
		}
	}
}
//
//#Preview {
//
//    NavigationBarBackButton()
//}
