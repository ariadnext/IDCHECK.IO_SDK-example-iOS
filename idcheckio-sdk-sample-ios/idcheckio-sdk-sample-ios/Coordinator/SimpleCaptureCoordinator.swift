//
//  SimpleCaptureCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 27/01/2021.
//

import Foundation
import IDCheckIOSDK

class SimpleCaptureCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    
    fileprivate let scenario: SDKScenario
    
    init(navigationController: UINavigationController, sdkScenario: SDKScenario) {
        self.navigationController = navigationController
        self.scenario = sdkScenario
    }
    
    func start() {
        activateSdk()
    }
}

fileprivate extension SimpleCaptureCoordinator {
    
    func activateSdk() {
        //Activate the SDK with your licence file provided by ARIADNEXT
        Idcheckio.shared.activate(withLicenseFilename: "licence.axt", extractData: true, sdkEnvironment: .demo) { (error) in
            if let activationError = error {
                self.parentCoordinator?.childDidFinish(self, result: .failure(activationError))
            } else {
                self.prepareSession()
            }
        }
    }
    
    func prepareSession() {
        //Set the prameters for your capture session
        guard let sdkParams = scenario.config?.sdkParams,
              let sdkExtraParams = scenario.config?.sdkExtraParams  else {
            parentCoordinator?.childDidFinish(self, result: .failure(ConfigError.emptyConfig))
            return
        }
        do {
            try Idcheckio.shared.setParams(sdkParams)
            Idcheckio.shared.extraParameters = sdkExtraParams
        } catch {
            parentCoordinator?.childDidFinish(self, result: .failure(error))
            return
        }
        startSdk()
    }
    
    func startSdk() {
        //Start the capture session
        let sessionController = IdcheckioViewController()
        sessionController.modalPresentationStyle = .fullScreen
        //Handle session result or error here
        sessionController.resultCompletion = { [weak self] (result) in
            guard let strongSelf = self else { return }
            //Dissmiss SDK controller when session is complete or an error occured
            DispatchQueue.main.async {
                strongSelf.navigationController.dismiss(animated: true, completion: {
                    //Go back to portrait orientaion when the sdk has finished
                    if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
                        myDelegate.supportedOrientation = .portrait
                    }
                    strongSelf.parentCoordinator?.childDidFinish(strongSelf, result: result)
                })
            }
        }
        //Enable all supported orientatons in App Delegate in order to launch the SDK in landscape if needed
        if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
            myDelegate.supportedOrientation = .all
        }
        navigationController.present(sessionController, animated: true)
    }
}
