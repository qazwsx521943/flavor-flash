//
//  AppDelegate.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import UIKit
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let env = {
            #if DEBUG
            return DebugENV()
            #else
            return ProdENV()
            #endif
        }()

        GMSPlacesClient.provideAPIKey(env.GOOGLE_MAP_API_KEY)
        return true
    }
}
