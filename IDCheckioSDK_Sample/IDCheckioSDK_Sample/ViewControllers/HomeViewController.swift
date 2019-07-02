//
//  HomeViewController.swift
//  IDCheckioSDK_Sample
//
//  Created by Arnaud Bretagne on 02/07/2019.
//  Copyright © 2019 ariadnext. All rights reserved.
//

import UIKit
import IDCheckIOSDK

typealias IDCheckIOResultCompletionBlock = (_ result: IdcheckioResult?, _ error: Error?) -> Void

class HomeViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            versionLabel.text = "SDK v.\(Idcheckio.shared.sdkVersion())"
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sdkInitialization()
    }
    
    private func sdkInitialization() {
        Idcheckio.shared.preload(extractData: true)
        Idcheckio.shared.delegate = self
        
        Idcheckio.shared.activate(withLicenseFilename: "licence", extractData: true) { (error: IdcheckioError?) in
            if let error = error {
                print("Error on initialization :\(error.localizedDescription)")

                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)

                return
            }

            print("Initialization successed !")
        }
    }
    
    // MARK: Actions
    @IBAction func startButtonTouchUpInside(_ sender: Any) {
        // ID Session
        launchSession(with: IDCheckIOUtil.idParams())
        
        // Liveness Session
//        launchSession(with: IDCheckIOUtil.livenessParams())
    }
}

extension HomeViewController {
    func launchSession(with param: SDKParams) {
        try? Idcheckio.shared.setParams(param)
        
        DispatchQueue.main.async { [weak self] in
            let viewController = UIViewController()
            let cameraView = IdcheckioView()
            
            cameraView.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.frame = self?.view.frame ?? .zero
            viewController.view.addSubview(cameraView)
            viewController.view.backgroundColor = UIColor.black
            cameraView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
            cameraView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
            cameraView.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
            cameraView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
            
            self?.present(viewController, animated: true, completion: { [cameraView] in
                Idcheckio.shared.start(with: cameraView, completion: { [weak self] (error) in
                    if let error = error {
                        print("Error \(error.localizedDescription)")
                        self?.display(result: nil, error: error)
                    }
                })
            })
        }
    }
}

extension HomeViewController: IdcheckioDelegate {
    
    func idcheckioFinishedWithResult(_ result: IdcheckioResult?, error: Error?) {
        DispatchQueue.main.async { [weak self, result, error] in
            self?.dismiss(animated: true, completion: { [weak self, result, error] in
                self?.display(result: result, error: error)
            })
        }
    }
    
    func idcheckioDidSendEvent(interaction: IdcheckioInteraction, msg: IdcheckioMsg?) {
        //Nothing to do...
    }
    
    func display(result: IdcheckioResult?, error: Error?) {
        var message: String = "No result"
        if let document = result?.document {
            switch document {
            case .identity(let idDocument):
                message = "Hello \(idDocument.fields[.firstNames]?.value ?? "") \(idDocument.fields[.lastNames]?.value ?? "")"
            }
        } else {
            message = error?.localizedDescription ?? "Unknown result"
        }
        
        showAlert(with: message)
    }
}

extension HomeViewController {
    func showAlert(with messsage: String) {
        DispatchQueue.main.async { [weak self, messsage] in
            let alert = UIAlertController(title: nil, message: messsage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
