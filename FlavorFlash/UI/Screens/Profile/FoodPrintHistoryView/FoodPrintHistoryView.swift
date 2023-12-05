//
//  FoodPrintHistoryView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import SwiftUI

struct FoodPrintHistoryView: View {
	
	@ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
		FoodPrintMapView(profileViewModel: profileViewModel)
			.navigationTitle("My FoodPrints")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar(.hidden, for: .tabBar)
    }
}

//#Preview {
//    FoodPrintHistoryView()
//}
