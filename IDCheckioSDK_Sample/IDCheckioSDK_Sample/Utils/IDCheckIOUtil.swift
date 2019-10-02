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
        
        params.scanBothSides = .enabled // if needed and available, will ask (or not), or force to scan the second side of the document
        params.confirmType = .dataOrPicture // ask a confirmation to the user during the session
        
        params.side1Extraction.codeline = .decoded
        params.side1Extraction.face = .enabled
        params.side2Extraction.codeline = .any
        params.side2Extraction.face = .disabled
        
        return params
    }
    
    
    static func livenessParams() -> SDKParams {
        let params = SDKParams()
        params.documentType = .liveness
        return params
    }
}
