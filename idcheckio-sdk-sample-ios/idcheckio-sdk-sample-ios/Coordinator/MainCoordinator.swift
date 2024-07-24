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

    fileprivate var onlineContext: OnlineContext?
    fileprivate var idResult: IdcheckioResult?

    fileprivate let myCustomTheme = Theme(foregroundColor: .white,
                                          backgroundColor: UIColor(red: 44/255, green: 58/255, blue: 71/255, alpha: 1),
                                          borderColor: UIColor(red: 96/255, green: 163/255, blue: 188/255, alpha: 1), // Dupain
                                          primaryColor: UIColor(red: 60/255, green: 99/255, blue: 130/255, alpha: 1), // Good samaritan
                                          titleColor: UIColor(red: 60/255, green: 99/255, blue: 130/255, alpha: 1), // Good samaritan
                                          textColor: UIColor(red: 10/255, green: 61/255, blue: 98/255, alpha: 1)) // Forest blues

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showMainView()
    }

    func showMainView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: HomeViewController.identifier) as? HomeViewController {
            vc.delegate = self
            if navigationController.viewControllers.isEmpty {
                navigationController.viewControllers = [vc]
            } else {
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }

    func askFolderUID() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: FolderUIDViewController.identifier) as? FolderUIDViewController {
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func startOnboardingFlow(with folder: String) {
        self.navigationController.popViewController(animated: true)
        // Active the IDcheckio sdk
        self.activateSdk { [weak self] in
            let currentViewController = self?.navigationController.topViewController ?? UIViewController()
            let myCustomization = OnboardingCustomization(theme: self?.myCustomTheme ?? Theme(), orientation: .portrait)
            Idcheckio.startOnboarding(with: folder,
                                      from: currentViewController,
                                      onboardingCustomization: myCustomization) { [weak self] result in
                switch result {
                case .success:
                    self?.displaySuccess(message: "Onboarding completed")
                case .failure(let error):
                    self?.displayError(error: "Start onboarding flow failed : \(error)")
                }
            }
        }

    }

    func startOnlineFlow() {
        // Active the IDcheckio sdk
        self.activateSdk { [weak self] in
            // Set params of the session
            let currentSessionConfig = SDKConfig.idDocument
            do {
                try Idcheckio.shared.setParams(currentSessionConfig.sdkParams)
                try Idcheckio.shared.setExtraParams(currentSessionConfig.sdkExtraParams)
            } catch let error {
                self?.displayError(error: "Set params and extra params of the SDK failed : \(error)")
                return
            }
            Idcheckio.shared.theme = self?.myCustomTheme ?? Theme()
            // Start the capture session
            let sessionController = IdcheckioViewController()
            // Give online context from your previous session to link your liveness to the right CIS folder.
            sessionController.onlineContext = self?.onlineContext
            sessionController.modalPresentationStyle = .fullScreen
            // Handle session result or error here
            sessionController.resultCompletion = { [weak self] in self?.handleSdkResult(result: $0) }
            self?.navigationController.present(sessionController, animated: true)
        }
    }

    private func handleSdkResult(result: Result<IdcheckioResult?, Error>) {
        // Dismiss SDK controller when session is complete or an error occured
        DispatchQueue.main.async {
            self.navigationController.dismiss(animated: true, completion: {
                switch result {
                case .success(let result):
                    guard let sessionResult = result else { return }
                    // Save the online context to give to next sessions.
                    self.onlineContext = sessionResult.onlineContext
                    self.showResult(result: sessionResult)
                case .failure(let error):
                    self.displayError(error: "SDK session failed : \(error)")
                }
            })
        }
    }

    private func showResult(result: IdcheckioResult?) {
        let viewModel = ResultViewMoodel(result: result)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ResultViewController.identifier ) as? ResultViewController {
            vc.viewModel =  viewModel
            navigationController.pushViewController(vc, animated: true)
        }
    }

    private func activateSdk(completion: @escaping () -> Void) {
        // Activate the SDK with your token provided by IDnow
        Idcheckio.shared.activate(withToken: Token.demo.rawValue, extractData: true) { [weak self] error in
            if let activationError = error {
                self?.displayError(error: "An error occured during activation of the SDK : \(activationError)")
            } else {
                completion()
            }
        }
    }
}

extension MainCoordinator: HomeDelegate {
    func handleTapOnOnlineFlow() {
        self.startOnlineFlow()
    }

    func handleTapOnOnboardingFlow() {
        self.askFolderUID()
    }
}
