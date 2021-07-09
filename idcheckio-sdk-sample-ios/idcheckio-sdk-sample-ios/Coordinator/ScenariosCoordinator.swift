//
//  ScenariosCoordinator.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 26/01/2021.
//

import UIKit
import IDCheckIOSDK

class ScenariosCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var scenarios: [SDKScenario]
    var anlyzeManager: AnalyzeManager?

    init(navigationController: UINavigationController,
         scenarios: [SDKScenario]) {
        self.navigationController = navigationController
        self.scenarios = scenarios
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ScenariosViewController.identifier) as? ScenariosViewController {
            vc.coordinator = self
            vc.scenarios = scenarios
            if navigationController.viewControllers.isEmpty {
                navigationController.viewControllers = [vc]
            } else {
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }

    func childDidFinish(_ child: Coordinator, result: Result<IdcheckioResult?, Error>) {
        switch result {
        case .success(let result):
            guard let result = result else { return }
            showResult(result: result)
        case .failure(let error):
            navigationController.popToRootViewController(animated: true)
            displayError(error: error.localizedDescription)
        }
    }

    func analyzeImages(_ images: (UIImage, UIImage?)) {
        self.anlyzeManager = AnalyzeManager()
        anlyzeManager?.start(images: images) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let result):
                weakSelf.showResult(result: result)
            case .failure(let error):
                weakSelf.displayError(error: error.localizedDescription)
            }
        }
    }

    func startScenario(_ scenario: SDKScenario?) {
        guard let scenario = scenario else { return }
        var sessionCoordinator: Coordinator
        switch scenario.captureType {
        case .simple:
            sessionCoordinator = SimpleCaptureCoordinator(navigationController: navigationController, sdkScenario: scenario)
        case .advanced:
            sessionCoordinator = AdvancedCaptureCoordinator(navigationController: navigationController,  sdkScenario: scenario)
        case .onlineFlow:
            sessionCoordinator = OnlineFlowCoordinator(navigationController: navigationController)
        default:
            return
        }
        sessionCoordinator.parentCoordinator = self
        self.childCoordinators.append(sessionCoordinator)
        sessionCoordinator.start()
    }
}

private extension ScenariosCoordinator {
    func showResult(result: IdcheckioResult?) {
        let viewModel = ResultViewMoodel(result: result)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ResultViewController.identifier ) as? ResultViewController {
            vc.viewModel =  viewModel
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
