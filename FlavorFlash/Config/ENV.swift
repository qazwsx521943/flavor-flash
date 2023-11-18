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
        case GOOGLE_MAP_API_KEY
        case GOOGLE_PLACE_API_KEY
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

extension BaseENV {
    func getValue(_ keyValue: String) -> String {
        guard 
            let key = dict.object(forKey: keyValue) as? String
        else {
            fatalError("Cannot get apiKey")
        }

        return key
    }
}

protocol APIKeyable {
    var GOOGLE_MAP_API_KEY: String { get }
    var GOOGLE_PLACE_API_KEY: String { get }
}

class DebugENV: BaseENV, APIKeyable {
    var GOOGLE_MAP_API_KEY: String {
        return getValue(Key.GOOGLE_MAP_API_KEY.rawValue)
    }

    var GOOGLE_PLACE_API_KEY: String {
        return getValue(Key.GOOGLE_PLACE_API_KEY.rawValue)
    }

    init() {
        super.init(resourceName: Env.DEBUG.rawValue)
    }
}

class ProdENV: BaseENV, APIKeyable {
    var GOOGLE_MAP_API_KEY: String {
        return getValue(Key.GOOGLE_MAP_API_KEY.rawValue)
    }

    var GOOGLE_PLACE_API_KEY: String {
        return getValue(Key.GOOGLE_PLACE_API_KEY.rawValue)
    }

    init() {
        super.init(resourceName: Env.PROD.rawValue)
    }
}
