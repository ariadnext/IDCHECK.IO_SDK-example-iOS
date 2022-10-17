//
//  IpsSessionCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 23/05/2022.
//

import UIKit
import IDCheckIOSDK

class IpsSessionCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        activateSdk()
    }
    
    func showIpsSession() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: IpsFlowViewController.identifier ) as? IpsFlowViewController {
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}

extension IpsSessionCoordinator {

    private func activateSdk() {
        // Activate the SDK with your token provided by ARIADNEXT
        Idcheckio.shared.activate(withToken: Token.demo.rawValue, extractData: true) { error in
            if let activationError = error {
                self.parentCoordinator?.childDidFinish(self, result: .failure(activationError))
            } else {
                self.showIpsSession()
            }
        }
    }
    
    func startSdk(file: String) {
        Idcheckio.startIps(with: "6e195ca9-73ea-4d73-bec6-9001b9cff41c", from: self.navigationController) { result in
            self.navigationController.popViewController(animated: true)
            switch result {
            case .success:
                self.parentCoordinator?.childDidFinish(self, result: .success(nil))
            case .failure(let error):
                self.parentCoordinator?.childDidFinish(self, result: .failure(error))
            }
        }
    }
}

