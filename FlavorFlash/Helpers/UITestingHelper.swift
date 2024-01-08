//
//  UITestingHelper.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2024/1/7.
//

#if DEBUG
// only run in debug build
import Foundation

struct UITestingHelper {
	
	static var isUITesting: Bool {
		ProcessInfo.processInfo.arguments.contains("-ui-testing")
	}
}

#endif
