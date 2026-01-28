//
//  HomeViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Léa Lefeuvre on 19/06/2024.
//

import UIKit

/// Main view, containing the two buttons: Online and Onboarding flow.
class HomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var appDescription: UILabel!
    @IBOutlet private weak var onlineButton: UIButton!
    @IBOutlet private weak var onboardingButton: UIButton!

    // MARK: - Identifier
    static let identifier = "HomeViewController"

    // MARK: - Delegate
    weak var delegate: HomeDelegate?

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Actions
    @IBAction func didTapOnlineFlow() {
        delegate?.handleTapOnOnlineFlow()
    }

    @IBAction func didTapOnboardingFlow() {
        delegate?.handleTapOnOnboardingFlow()
    }
}

// MARK: - Private methods
private extension HomeViewController {
    func setupView() {
        appDescription.text = "This is the official sample of the IDCheck.io SDK, a by-product of IDcheck.io produced by IDnow. You will find two examples of sdk integration there, you are free to look at the one that best meets your needs.\n\nWarning, to run this sample you will need a token, for more information you can contact us at the following address: csm@idnow.io"

        onlineButton.layer.cornerRadius = onlineButton.frame.height / 2
        onlineButton.backgroundColor = UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 1)
        onlineButton.tintColor = UIColor.white
        onlineButton.setTitle("Online flow", for: .normal)
        onlineButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        onlineButton.titleLabel?.textColor = UIColor.white
        onlineButton.titleEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        onboardingButton.layer.cornerRadius = onboardingButton.frame.height / 2
        onboardingButton.backgroundColor = UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 1)
        onboardingButton.tintColor = UIColor.white
        onboardingButton.setTitle("Onboarding flow", for: .normal)
        onboardingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        onboardingButton.titleLabel?.textColor = UIColor.white
        onboardingButton.titleEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
}
