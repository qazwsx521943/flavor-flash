//
//  FFTag.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/24.
//

import SwiftUI

struct FFTag: View {

	var displayText: String

    var body: some View {
        Text(displayText)
			.padding()
			.background(.red)
    }
}

#Preview {
    FFTag(displayText: "Hamburger")
}
