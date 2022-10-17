//
//  Coordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 26/01/2021.
//

import UIKit
import IDCheckIOSDK

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }
    
    func start()
    func childDidFinish(_ child: Coordinator, result: Result<IdcheckioResult?, Error>)
    func displayError(error: String)
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator, result: Result<IdcheckioResult?, Error>) {}
    func displayError(error: String) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}
