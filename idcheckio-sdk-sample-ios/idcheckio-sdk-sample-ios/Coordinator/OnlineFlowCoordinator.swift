//
//  OnlineFlowCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 09/03/2021.
//

import UIKit
import IDCheckIOSDK

class OnlineFlowCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    
    fileprivate var onlineContext: OnlineContext?
    fileprivate var idResult: IdcheckioResult?
    fileprivate let configs: [SDKConfig] = [.idOnline, .liveness]
    fileprivate var index = 0 {
        didSet {
            if index == configs.count {
                parentCoordinator?.childDidFinish(self, result: .success(idResult))
            } else {
                self.showSessionController()
            }
        }
    }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        activateSdk()
    }

    func startSession() {
        //Set the prameters for your capture session
        let sdkParams = configs[index].sdkParams
        let sdkExtraParams = configs[index].sdkExtraParams
        switch sdkParams.documentType {
        case .id:
            //Set isReferenceDocument to `true` for an ID that will be a reference document for the liveness session.
            sdkParams.onlineConfig.isReferenceDocument = true
        default:
            break
        }
        do {
            try Idcheckio.shared.setParams(sdkParams)
            try Idcheckio.shared.setExtraParams(sdkExtraParams)
        } catch {
            parentCoordinator?.childDidFinish(self, result: .failure(error))
            return
        }
        startSdk()
    }
}

fileprivate extension OnlineFlowCoordinator {

    func activateSdk() {
        // Activate the SDK with your token provided by ARIADNEXT
        Idcheckio.shared.activate(withToken: Token.demo.rawValue, extractData: true) { error in
            if let activationError = error {
                self.parentCoordinator?.childDidFinish(self, result: .failure(activationError))
            } else {
                self.showSessionController()
            }
        }
    }

    func showSessionController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: OnlineFlowViewController.identifier ) as? OnlineFlowViewController {
            vc.documentType = configs[index].sdkParams.documentType
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func startSdk() {
        //Start the capture session
        let sessionController = IdcheckioViewController()
        //Specifies that you want an online session
        sessionController.isOnlineSession = true
        //Give online context from your previous session to link your liveness to the right CIS folder.
        sessionController.onlineContext = onlineContext
        sessionController.modalPresentationStyle = .fullScreen
        //Handle session result or error here
        sessionController.resultCompletion = { [weak self] in self?.handleSdkResult(result: $0) }
        //Enable all supported orientatons in App Delegate in order to launch the SDK in landscape if needed
        if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
            myDelegate.supportedOrientation = .all
        }
        navigationController.present(sessionController, animated: true) { [weak self] in
            // Remove previous OnlineFlowViewController.
            if let index = self?.navigationController.viewControllers.firstIndex(where: {$0 is OnlineFlowViewController} ) {
                self?.navigationController.viewControllers.remove(at: index)
            }
        }
    }

    func handleSdkResult(result: Result<IdcheckioResult?, Error>) {
        //Dismiss SDK controller when session is complete or an error occured
        DispatchQueue.main.async {
            self.navigationController.dismiss(animated: true, completion: {
                //Go back to portrait orientaion when the sdk has finished
                if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
                    myDelegate.supportedOrientation = .portrait
                }
                switch result {
                case .success(let result):
                    guard let sessionResult = result else { return }
                    //Save the online context to give to next sessions.
                    self.onlineContext = sessionResult.onlineContext
                    switch sessionResult.document {
                    case .identity:
                        self.idResult = result
                    default:
                        break
                    }
                    self.index += 1
                case .failure(let error):
                    self.parentCoordinator?.childDidFinish(self, result: .failure(error))
                }
            })
        }
    }
}
