//
//  FolderUIDViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Léa Lefeuvre on 27/06/2024.
//

import UIKit

class FolderUIDViewController: UIViewController {

    weak var coordinator: MainCoordinator?

    static let identifier = "FolderUIDViewController"

    // MARK: - Outlets
    @IBOutlet weak private var headerLabel: UILabel! {
        didSet {
            headerLabel.text = "Enter your folder UID"
        }
    }
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var footerLabel: UILabel!
    @IBOutlet weak private var button: UIButton!

    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 1)
        navigationController?.navigationBar.isHidden = false

        textField.placeholder = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX"
        textField.delegate = self

        footerLabel.text = "Enter folderUID. If you are using a certified onboarding, you will need to get the folder UID from our IPS service. Please contact customer support for more information."

        button.layer.cornerRadius = button.frame.height / 2
        button.backgroundColor = UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 1)
        button.tintColor = UIColor.white
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.titleLabel?.textColor = UIColor.white
        button.titleEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        // Add tap gesture for keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - IBAction
    @IBAction func startAction(_ sender: Any) {
        guard textField.text?.isEmpty == false else {
            coordinator?.displayError(error: "File UID must not be empty")
            return
        }
        coordinator?.startOnboardingFlow(with: textField.text ?? "")
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
// MARK: - UITextFieldDelegate
extension FolderUIDViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
