//
//  AnalyzeManager.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 04/03/2021.
//

import Foundation
import IDCheckIOSDK

class AnalyzeManager {

    var finishCompletion: ((Result<IdcheckioResult?, Error>) -> ())?

    func start(images: (UIImage, UIImage?), completion: ((Result<IdcheckioResult?, Error>) -> ())?) {
        self.finishCompletion = completion
        // Activate the SDK with your token provided by ARIADNEXT
        Idcheckio.shared.activate(withToken: Token.demo.rawValue, extractData: true) { (error) in
            if let activationError = error {
                self.finishCompletion?(.failure(activationError))
                return
            }
            let params = SDKConfig.id.sdkParams
            params.integrityCheck = IntegrityCheck() // Disable readEmrtd for analyze session.
            do {
                try Idcheckio.shared.setParams(params)
            }
            catch {
                self.finishCompletion?(.failure(error))
                return
            }
            Idcheckio.shared.delegate = self
            Idcheckio.shared.analyze(side1Image: images.0, side2Image: images.1)
        }
    }
}

extension AnalyzeManager: IdcheckioDelegate {
    func idcheckioFinishedWithResult(_ result: IdcheckioResult?, error: Error?) {
        if let error = error {
            finishCompletion?(.failure(error))
            return
        }
        finishCompletion?(.success(result))
    }

    func idcheckioDidSendEvent(interaction: IdcheckioInteraction, msg: IdcheckioMsg?) {
        // Not used here.
    }
}
