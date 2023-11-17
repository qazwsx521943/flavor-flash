//
//  FlavorFlashApp.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

@main
struct FlavorFlashApp: App {
    @StateObject private var ENV: BaseENV = {
        #if DEBUG
            return DebugENV()
        #else
            return ProdENV()
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ENV)
        }
    }
}
