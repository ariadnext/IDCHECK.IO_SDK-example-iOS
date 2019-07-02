//
//  IDCheckIOUtil.swift
//  IDCheckioSDK_Sample
//
//  Created by Arnaud Bretagne on 02/07/2019.
//  Copyright © 2019 ariadnext. All rights reserved.
//

import Foundation
import IDCheckIOSDK

class IDCheckIOUtil {
    
    static func idParams() -> SDKParams {
        let params = SDKParams()
        
        params.documentType = .id
        
        params.feedbackLevel = .all
        params.scanBothSides = .enabled
        params.confirmType = .dataOrPicture
        
        params.side1Extraction.codeline = .decoded
        params.side1Extraction.face = true
        params.side2Extraction.codeline = .any
        params.side2Extraction.face = false
        
        return params
    }
    
    
    static func livenessParams() -> SDKParams {
        let params = SDKParams()
        params.documentType = .liveness
        return params
    }
}
