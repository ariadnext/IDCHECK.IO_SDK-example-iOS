//
//  HomeDelegate.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Nabil LAHLOU on 31/10/2025.
//

/// Delegate of home view controller
@MainActor
protocol HomeDelegate: AnyObject {
    func handleTapOnOnlineFlow()
    func handleTapOnOnboardingFlow()
}
