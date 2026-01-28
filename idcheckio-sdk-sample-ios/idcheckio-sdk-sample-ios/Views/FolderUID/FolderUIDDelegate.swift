//
//  FolderUIDDelegate.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Nabil LAHLOU on 31/10/2025.
//

/// Delegate of home FolderUID view controller,
@MainActor
protocol FolderUIDDelegate: AnyObject {
    func startOnboarding(with folderUID: String)
    func onError(error: String)
}
