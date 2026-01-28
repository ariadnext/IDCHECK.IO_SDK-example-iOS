//
//  MainCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 26/01/2021.
//

import UIKit
import IDCheckIOSDK

/// Coordinator that will handle view controllers
@MainActor
class MainCoordinator {
    // MARK: - Properties
    private var onlineContext: OnlineContext?
    private var idResult: IdcheckioResult?
    private var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator methods
    func start() {
        showMainView()
    }
}

// MARK: - HomeDelegate methods
@MainActor
extension MainCoordinator: HomeDelegate {
    func handleTapOnOnlineFlow() {
        startOnlineFlow()
    }

    func handleTapOnOnboardingFlow() {
        self.askFolderUID()
    }
}

// MARK: - FolderUIDDelegate methods
@MainActor
extension MainCoordinator: FolderUIDDelegate {
    func startOnboarding(with folderUID: String) {
        startOnboardingFlow(with: folderUID)
    }

    func onError(error: String) {
        displayError(error: error)
    }
}

// MARK: - Private methods
@MainActor
private extension MainCoordinator {
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
            vc.delegate = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    /// Activates the SDK
    /// - returns true if the SDK is activated, false elsewhere
    func activateSdk() async -> Bool {
        do {
            try await Idcheckio.activate(withToken: Token.demo.rawValue, extractData: true)
            return true
        } catch {
            displayError(error: "An error occured during activation of the SDK : \(error)")
            return false
        }
    }

    func startOnlineFlow() {
        Task(priority: .userInitiated) { @MainActor in
            // Activate the IDcheckio sdk
            let isSDKActivated = await activateSdk()
            guard isSDKActivated else { return }

            do {
                // Get the result
                let sessionResult = try await Idcheckio.startSession(onlineContext: onlineContext,
                                                                     sdkParams: SDKConfig.idDocument.sdkParams,
                                                                     sdkExtraParams: SDKConfig.idDocument.sdkExtraParams)
                // Save the online context for future use if needed
                self.onlineContext = sessionResult?.onlineContext

                // Show the result
                self.showResult(result: sessionResult)
            } catch {
                self.displayError(error: "SDK session failed : \(error)")
            }
        }
    }

    func startOnboardingFlow(with folderUID: String) {
        Task(priority: .userInitiated) { @MainActor in
            navigationController.popViewController(animated: true)

            // Activate the IDcheckio sdk
            let isSDKActivated = await activateSdk()
            guard isSDKActivated else { return }

            do {
                // Start the onboarding flow.
                // No result is needed, as everything is handled by the SDK in this mode !
                try await Idcheckio.startOnboarding(with: folderUID)
                displaySuccess(message: "Onboarding completed")
            } catch {
                displayError(error: "Start onboarding flow failed : \(error)")
            }
        }
    }

    func showResult(result: IdcheckioResult?) {
        let viewModel = ResultViewModel(result: result)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ResultViewController.identifier ) as? ResultViewController {
            vc.viewModel =  viewModel
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func displaySuccess(message: String) {
        let alert = UIAlertController(title: "🎉 Success", message: message.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.navigationController.present(alert, animated: true, completion: nil)
    }

    func displayError(error: String) {
        let alert = UIAlertController(title: "❌ Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}
