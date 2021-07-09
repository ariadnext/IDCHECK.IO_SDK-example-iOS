//
//  AdvancedCaptureCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 08/02/2021.
//

import UIKit
import IDCheckIOSDK

class AdvancedCaptureCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    
    fileprivate var scenario: SDKScenario
    
    init(navigationController: UINavigationController, sdkScenario: SDKScenario) {
        self.navigationController = navigationController
        self.scenario = sdkScenario
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        Idcheckio.shared.activate(withLicenseFilename: "licence.axt", extractData: true, sdkEnvironment: .demo) { error in
            if let activationError = error {
                self.parentCoordinator?.childDidFinish(self, result: .failure(activationError))
            } else {
                if let sessionController = storyboard.instantiateViewController(withIdentifier: AdvancedSessionViewController.storyboardIdentifier) as? AdvancedSessionViewController {
                    sessionController.scenario = self.scenario
                    sessionController.coordinator = self
                    //Enable all supported orientatons in App Delegate in order to launch the SDK in landscape if needed
                    if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
                        myDelegate.supportedOrientation = .all
                    }
                    self.navigationController.pushViewController(sessionController, animated: true)
                }
            }
        }
    }

    func showResult(_ result: Result<IdcheckioResult?, Error>) {
        //Go back to portrait orientaion when the sdk has finished
        navigationController.popToRootViewController(animated: true)
        if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
            myDelegate.supportedOrientation = .portrait
        }
        parentCoordinator?.childDidFinish(self, result: result)
    }
}
