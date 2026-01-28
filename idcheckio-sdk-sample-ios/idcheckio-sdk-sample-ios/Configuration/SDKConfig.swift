//
//  SDKConfig.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Anthony Dedieu on 09/07/2021.
//

import Foundation
import IDCheckIOSDK

/// Configuration to use in an `Online` sdk session.
enum SDKConfig {
    case idDocument
    case selfie
    case iban
    case vehicleRegistration
    case addressProof
    case frenchHealthCard
    case liveness

    /// Best practice parameters for each session type.
    var sdkParams: SDKParams {
        let params = SDKParams()
        switch self {
        case .idDocument:
            params.documentType = .id
            params.orientation = .portrait
            params.onlineConfig.isReferenceDocument = true
        case .selfie:
            params.documentType = .selfie
            params.orientation = .portrait
            params.confirmType = .croppedPicture
            params.useHD = true
        case .iban:
            params.documentType = .photo
            params.onlineConfig.cisType = .iban
            params.orientation = .portrait
            params.confirmType = .croppedPicture
        case .vehicleRegistration:
            params.documentType = .vehicleRegistration
            params.confirmType = .croppedPicture
            let extractionSide1 = Extraction()
            extractionSide1.codeline = .valid
            extractionSide1.face = .disabled
            params.side1Extraction = extractionSide1
            params.orientation = .portrait
        case .addressProof:
            params.documentType = .a4
            params.onlineConfig.cisType = .addressProof
            params.orientation = .portrait
            params.confirmType = .croppedPicture
            params.useHD = true
        case .frenchHealthCard:
            params.documentType = .frenchHealthCard
            params.confirmType = .croppedPicture
            params.orientation = .portrait
        case .liveness:
            params.documentType = .liveness
            params.orientation = .portrait
        }
        return params
    }

    /// Best practice extra parameters for each session type.
    var sdkExtraParams: SDKExtraParams {
        let extraParams = SDKExtraParams()
        switch self {
        case .liveness:
            extraParams.confirmAbort = true
        case .iban:
            extraParams.adjustCrop = true
        default:
            break
        }
        return extraParams
    }
}
