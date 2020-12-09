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
    @IBOutlet private weak var versionLabel: UILabel! {
        didSet {
            versionLabel.text = "SDK v.\(Idcheckio.shared.sdkVersion())"
        }
    }
    @IBOutlet private weak var idSwitch: UISwitch!
    @IBOutlet private weak var livenessSwitch: UISwitch!
    @IBOutlet private weak var sessionTypeSwitch: UISwitch!

    // MARK: Properties
    var selectedParams: SDKParams?
    var previousResult: IdcheckioResult?

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sdkInitialization()
    }

    private func sdkInitialization() {
        // Optimize SDK loading using this line:
        Idcheckio.shared.preload(extractData: true)
        Idcheckio.shared.delegate = self

        // Activate SDK with your licence file (name it "licence.axt" and place it in the root of the project folder)
        Idcheckio.shared.activate(withLicenseFilename: "licence", extractData: true, sdkEnvironment: .demo) { (error: IdcheckioError?) in
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

        if let params = selectedParams {
            try? Idcheckio.shared.setParams(params)
            launchSession(online: sessionTypeSwitch.isOn)
        } else {
            showAlert(with: "Please select a document type to start a session.")
        }
    }

    @IBAction func clearContextTouchUpInside(_ sender: Any) {
        previousResult = nil
        showAlert(with: "Context cleared !")
    }

    @IBAction func docTypeSwitchValueChanged(_ sender: Any) {
        guard let switchSender = sender as? UISwitch else { return }

        if switchSender.isOn {
            switch switchSender {
            case idSwitch:
                selectedParams = IDCheckIOUtil.idParams()
            case livenessSwitch:
                selectedParams = IDCheckIOUtil.livenessParams()
            default: break
            }
        } else {
            selectedParams = nil
        }

        [idSwitch, livenessSwitch].filter({ $0 != switchSender }).forEach { $0?.setOn(false, animated: true) }
    }
}

extension HomeViewController {
    func launchSession(online: Bool) {
        if !online && selectedParams?.documentType == .liveness {
            // TODO: Add your LIVENESS TOKEN - Retrieved from your custom CIS Gateway integration
            let livenessToken: String = "YOUR_LIVENESS_SESSION_TOKEN"
            Idcheckio.shared.extraParameters.token = livenessToken
        }


        DispatchQueue.main.async { [weak self, online] in
            let viewController = UIViewController()
            viewController.modalPresentationStyle = .fullScreen

            let cameraView = IdcheckioView(frame: .zero)

            cameraView.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.frame = self?.view.frame ?? .zero
            viewController.view.addSubview(cameraView)
            viewController.view.backgroundColor = UIColor.black
            cameraView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
            cameraView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
            cameraView.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
            cameraView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true

            self?.present(viewController, animated: true, completion: { [self, cameraView, online] in
                if online {
                    let referenceTaskUid = self?.previousResult?.taskUid
                    let referenceDocUid = self?.previousResult?.documentUid
                    let folderUid = self?.previousResult?.folderUid
                    let context = CISContext(folderUid: folderUid, referenceTaskUid: referenceTaskUid, referenceDocUid: referenceDocUid)
                    Idcheckio.shared.startOnline(with: cameraView,
                                                 cisContext: context,
                                                 completion: { [weak self] (error) in
                                                    if let error = error {
                                                        DispatchQueue.main.async {
                                                            self?.dismiss(animated: true) {
                                                                self?.display(result: nil, error: error)
                                                            }
                                                        }
                                                    }
                                                 })
                } else {
                    Idcheckio.shared.start(with: cameraView, completion: { [weak self] (error) in
                        if let error = error {
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true) {
                                    self?.display(result: nil, error: error)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
}

extension HomeViewController: IdcheckioDelegate {

    func idcheckioFinishedWithResult(_ result: IdcheckioResult?, error: Error?) {
        previousResult = result
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
        var message: String = "Thank you for your session !"
        if let document = result?.document {
            switch document {
            case .identity(let idDocument):
                message = "Hello \(idDocument.fields[.firstNames]?.value ?? "") \(idDocument.fields[.lastNames]?.value ?? "")"
            case .vehicleRegistration(let registrationDoc):
                message = "\(registrationDoc.fields[.make]?.value ?? "") \(registrationDoc.fields[.model]?.value ?? "")"
            }
        } else if let error = error {
            message = error.localizedDescription
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
