//
//  FBOfferCandidate.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/25.
//

import Foundation
import WebRTC

struct FBOfferCandidate: FBModelType {
	var id: String
	var sdp: String
	var type: SdpType
}

extension FBOfferCandidate {

}
