//
//  SDKScenario.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 25/01/2021.
//

import Foundation


enum CaptureType {
    case onlineFlow
    case simple
    case advanced
    case analyze
    
    var displayName: String {
        switch self {
        case .simple:
            return "Simple capture"
        case .advanced:
            return "Advanced capture"
        case .analyze:
            return "Analyze"
        case .onlineFlow:
            return "Online Flow"
        }
    }
    
    var description: String {
        switch self {
        case .simple:
            return "This sample offers the most basic capture.\nYou must choose a document type here:"
        case .advanced:
            return "This example shows you how to use the advanced interaction to customize the UI.\nYou must choose a document type here:"
        case .analyze:
            return "This example shows you how to use the analyze API to use an image of an ID you already have on your phone."
        case .onlineFlow:
            return "This example shows you how to easily integrate the SDK into an online flow.\nIn this example, our flow includes an ID and a LIVENESS"
        }
    }
    
    var footer: String {
        switch self {
        case .analyze, .onlineFlow:
            return ""
        default:
            return "The sdk will then be configured with the recommended settings for this type of document."
        }
    }
}

class SDKScenario: Equatable {

    internal init(captureType: CaptureType) {
        self.captureType = captureType
        self.config = availableConfigs.first
        if captureType == .analyze || captureType == .onlineFlow {
            availableConfigs.removeAll()
        }
    }
    
    var captureType: CaptureType
    var config: SDKConfig?
    var availableConfigs: [SDKConfig] = SDKConfig.scenarioConfigs

    static func == (lhs: SDKScenario, rhs: SDKScenario) -> Bool {
        return lhs.captureType == rhs.captureType
            && lhs.config == rhs.config
    }
}
