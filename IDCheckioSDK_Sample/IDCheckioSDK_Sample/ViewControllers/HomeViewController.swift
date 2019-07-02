//
//  HomeViewController.swift
//  IDCheckioSDK_Sample
//
//  Created by Arnaud Bretagne on 02/07/2019.
//  Copyright © 2019 ariadnext. All rights reserved.
//

import UIKit
import IDCheckIOSDK

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
        // ID PARAMS
        let params = IDCheckIOUtil.idParams()
        // LIVENESS PARAMS
//        let params = IDCheckIOUtil.livenessParams()
        
        do {
            try Idcheckio.shared.setParams(params)
        } catch {
            print(error)
        }
        
        
    }
}
