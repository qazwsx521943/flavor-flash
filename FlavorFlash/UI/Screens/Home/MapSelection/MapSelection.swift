//
//  MapSelection.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/9.
//

import SwiftUI

struct MapSelection: View {

	@Binding var maxResultValue: Double

	@Binding var searchRadius: Double

	@Binding var rankPreference: PlaceFetcher.RankPreference

    var body: some View {
		VStack {
			Text("Map Search Options")
				.bodyBoldStyle()

			Text("Max Search Result: \(Int(maxResultValue))")
				.bodyStyle()
			Slider(value: $maxResultValue, in: 1...20, step: 1) {
				Text("Result Count")
			} minimumValueLabel: {
				Text("0")
			} maximumValueLabel: {
				Text("20")
			}

			Text("Search Radius: \(Int(searchRadius)) meters")
				.bodyStyle()
			Slider(value: $searchRadius, in: 100...5000) {
				Text("search radius")
			} minimumValueLabel: {
				Text("100")
			} maximumValueLabel: {
				Text("5000")
			}

			Text("Rank Preference")
				.bodyStyle()

			Picker(selection: $rankPreference) {
				Text("Distance")
					.tag(PlaceFetcher.RankPreference.distance)

				Text("Popularity")
					.tag(PlaceFetcher.RankPreference.popularity)
			} label: {
				Text("Rank Preference: ")
			}
			.pickerStyle(.segmented)
			
			Spacer()
		}
		.detailBoldStyle()
    }
}

#Preview {
	MapSelection(maxResultValue: .constant(2.0), searchRadius: .constant(300.0), rankPreference: .constant(.popularity))
}

