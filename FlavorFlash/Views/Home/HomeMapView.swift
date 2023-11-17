//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import MapKit

struct HomeMapView: View {
    @EnvironmentObject private var navigationModel: NavigationModel

    let cityHallLocation = CLLocationCoordinate2D(latitude: 37.7793, longitude: -122.4193)
    let publicLibraryLocation = CLLocationCoordinate2D(latitude: 37.7785, longitude: -122.4156)
    let playgroundLocation = CLLocationCoordinate2D(latitude: 37.7802, longitude: -122.4214)

    var body: some View {
        VStack {
            Text("hi")
        }
        .navigationTitle("MAP")
    }
}

#Preview {
    HomeMapView()
        .environmentObject(NavigationModel())
}
