//
//  AppDelegate.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 22/01/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var supportedOrientation: UIInterfaceOrientationMask = .portrait

    var coordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true

        coordinator = MainCoordinator(navigationController: navigationController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        coordinator?.start()
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return supportedOrientation
    }
}
