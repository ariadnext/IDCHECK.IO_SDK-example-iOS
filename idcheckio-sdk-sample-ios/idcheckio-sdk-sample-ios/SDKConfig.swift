//
//  SDKConfig.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Anthony Dedieu on 09/07/2021.
//

import Foundation
import IDCheckIOSDK

enum ConfigError: Error {
    case emptyConfig
}

enum SDKConfig: String {
    case idOffline = "ID"
    case idOnline = "ID_ONLINE"
    case selfie = "SELFIE"
    case iban = "IBAN"
    case vehicleRegistration = "VEHICLE_REGISTRATION"
    case addressProof = "ADDRESS_PROOF"
    case frenchHealthCard = "FRENCH_HEALTH_CARD"
    case liveness = "LIVENESS"

    static var scenarioConfigs: [SDKConfig] {
        return [.idOffline,
                .selfie,
                .iban,
                .vehicleRegistration,
                .addressProof,
                .frenchHealthCard]
    }

    // Best practice parameters for each session type.
    var sdkParams: SDKParams {
        let params = SDKParams()
        switch self {
        case .idOffline:
            params.documentType = .id
            params.confirmType = .dataOrPicture
            params.scanBothSides = .enabled
            let extractionSide1 = Extraction()
            extractionSide1.codeline = .valid
            extractionSide1.face = .enabled
            params.side1Extraction = extractionSide1
            let extractionSide2 = Extraction()
            extractionSide2.codeline = .reject
            extractionSide2.face = .disabled
            params.side2Extraction = extractionSide2
            params.orientation = .portrait
        case .idOnline:
            params.documentType = .id
            params.orientation = .portrait
        case .selfie:
            params.documentType = .selfie
            params.orientation = .portrait
            params.confirmType = .dataOrPicture
            params.useHD = true
        case .iban:
            params.documentType = .photo
            params.onlineConfig.cisType = .iban //Needed for online session.
            params.orientation = .portrait
            params.confirmType = .dataOrPicture
        case .vehicleRegistration:
            params.documentType = .vehicleRegistration
            params.confirmType = .dataOrPicture
            let extractionSide1 = Extraction()
            extractionSide1.codeline = .valid
            extractionSide1.face = .disabled
            params.side1Extraction = extractionSide1
            params.orientation = .portrait
        case .addressProof:
            params.documentType = .a4
            params.onlineConfig.cisType = .addressProof //Needed for online session.
            params.orientation = .portrait
            params.confirmType = .dataOrPicture
            params.useHD = true
        case .frenchHealthCard:
            params.documentType = .frenchHealthCard
            params.confirmType = .dataOrPicture
            params.orientation = .portrait
        case .liveness:
            params.documentType = .liveness
            params.orientation = .portrait
        }
        return params
    }

    // Best practice extra parameters for each session type.
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
