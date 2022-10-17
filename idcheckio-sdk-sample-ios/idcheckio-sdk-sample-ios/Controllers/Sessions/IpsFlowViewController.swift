//
//  IpsFlowViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 24/05/2022.
//

import UIKit

class IpsFlowViewController: UIViewController {

    static let identifier = "IpsFlowViewController"
    
    weak var coordinator: IpsSessionCoordinator?
    
    // MARK: - Outlets
    @IBOutlet weak private var headerLabel: UILabel! {
        didSet {
            headerLabel.text = "Enter your folder UID"
        }
    }
    @IBOutlet weak private var textField: UITextField!  {
        didSet {
            textField.placeholder = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX"
        }
    }
    @IBOutlet weak private var footerLabel: UILabel! {
        didSet {
            footerLabel.text = "Folder UID can be request  to the IPS service. Please contact customer support for more information."
        }
    }
    @IBOutlet weak private var button: UIButton! {
        didSet {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(named: "BlueAriadnext")
            button.setTitle("START", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func startAction(_ sender: Any) {
        guard textField.text?.isEmpty == false else {
            coordinator?.showAlert(error: "File UID must not be empty")
            return
        }
        coordinator?.startSdk(file: textField.text ?? "")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
