//
//  OnlineFlowViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 09/03/2021.
//

import UIKit
import IDCheckIOSDK

class OnlineFlowViewController: UIViewController {

    static let identifier = "OnlineFlowViewControllerIdentifier"
    
    @IBOutlet weak private var stepDescription: UILabel! {
        didSet {
            guard let documentType = self.documentType else { return }
            switch documentType {
            case .id:
                stepDescription.text = "To verify your identity, we will start by scanning your identity card."
            case .liveness:
                stepDescription.text = "We will now verify that you are the holder of this identity"
            default:
                break
            }
        }
    }
    @IBOutlet weak private var startButton: UIButton! {
        didSet {
            startButton.layer.borderWidth = 3.0
            startButton.layer.borderColor = UIColor(named: "BlueAriadnext")?.cgColor
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(UIColor(named: "BlueAriadnext"), for: .normal)
        }
    }

    var documentType: DocumentType?
    weak var coordinator: OnlineFlowCoordinator?
    
    @IBAction func startButtonDidTap(_ sender: Any) {
        coordinator?.startSession()
    }
}
