//
//  MainCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 26/01/2021.
//

import UIKit
import IDCheckIOSDK

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    
    var scenarios: [SDKScenario] = [SDKScenario(captureType: .onlineFlow),
                                    SDKScenario(captureType: .simple),
                                    SDKScenario(captureType: .ips),
                                    SDKScenario(captureType: .analyze)]
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showScenarios()
    }
    
    func showScenarios () {
        let coordinator = ScenariosCoordinator(navigationController: navigationController, scenarios: scenarios)
        coordinator.parentCoordinator = self
        self.childCoordinators.append(coordinator)
        coordinator.start()
    }
}
