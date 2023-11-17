//
//  ENV.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import SwiftUI

class BaseENV: ObservableObject {
    let dict: NSDictionary

    enum Key: String {
        // swiftlint:disable identifier_name
        case GOOGLE_MAP_API_KEY
    }

    enum Env: String {
        case DEBUG = "DEBUG-Keys"
        case PROD = "PROD-Keys"
    }

    init(resourceName: String) {
        guard
            let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: filePath)
        else {
            fatalError("Cannot find file \(resourceName) plist")
        }
        self.dict = plist
    }
}

protocol APIKeyable {
    // swiftlint:disable identifier_name
    var GOOGLE_MAP_API_KEY: String { get }
}

class DebugENV: BaseENV, APIKeyable {
    // swiftlint:disable identifier_name
    var GOOGLE_MAP_API_KEY: String {
        guard
            let key = dict.object(forKey: Key.GOOGLE_MAP_API_KEY.rawValue) as? String
        else { fatalError("cannot get apikey") }

        return key
    }

    init() {
        super.init(resourceName: Env.DEBUG.rawValue)
    }
}

class ProdENV: BaseENV, APIKeyable {
    // swiftlint:disable identifier_name
    var GOOGLE_MAP_API_KEY: String {
        guard let key = dict.object(forKey: Key.GOOGLE_MAP_API_KEY.rawValue) as? String
        else { fatalError("cannot get apikey") }

        return key
    }

    init() {
        super.init(resourceName: Env.PROD.rawValue)
    }
}
