//
//  ViewController.swift
//  idcheckio-example
//
//  Created by Denis Jagoudel on 03/04/2017.
//  Copyright © 2017 Denis Jagoudel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var recto: UIImageView!
    @IBOutlet var verso: UIImageView!
    @IBOutlet var data: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sdkInit: AXTSdkInit = AXTSdkInit()
        sdkInit.licenseFilename = "licence"
        sdkInit.timeoutActivation = 20
        
        if(!AXTCaptureInterface.captureInterfaceInstance().sdkIsActivated()){
            AXTCaptureInterface.captureInterfaceInstance().initCaptureSdk(sdkInit, withCompletion: { (result, error) in
                if(error == nil){
                    NSLog("Initilization successed!")
                } else {
                    NSLog("Error on initialization : %@", error ?? "Init error")
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onScan(_ sender: Any) {
        startSmartsdk()
    }
    
    func addObserversForSDK() {
        NSLog("Add observers for SDK result")
        NotificationCenter.default.addObserver(self, selector: #selector(getSdkResult(_:)), name: NSNotification.Name(rawValue: SMARTSDK_RESULT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(smartsdkCancelled), name: NSNotification.Name(rawValue: SMARTSDK_CANCELLED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(smartsdkCrash(_:)), name: NSNotification.Name(rawValue: SMARTSDK_CRASH), object: nil)
    }
    
    func removeObserversForSDK() {
        NSLog("Remove observers for SDK result")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SMARTSDK_RESULT), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SMARTSDK_CANCELLED), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SMARTSDK_CRASH), object: nil)
    }

    func startSmartsdk() {
        addObserversForSDK()
        NSLog("Start SDK IDCHECK.IO")
        let sdkParams: AXTSdkParams = AXTSdkParams()
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters.setObject(true, forKey:"EXTRACT_DATA" as NSCopying)
        parameters.setObject(true, forKey:"DISPLAY_RESULT" as NSCopying)
        parameters.setObject(true, forKey:"SCAN_BOTH_SIDE" as NSCopying)
        parameters.setObject(true, forKey:"USE_HD" as NSCopying)
        parameters.setObject(false, forKey:"USE_FRONT_CAMERA" as NSCopying)
        parameters.setObject("MRZ_FOUND", forKey:"DATA_EXTRACTION_REQUIREMENT" as NSCopying)
        
        let extraParams: NSMutableDictionary = NSMutableDictionary()
        extraParams.setObject(15, forKey:AXT_MANUAL_BUTTON_TIMER as NSCopying)
        
        sdkParams.doctype = .ID
        sdkParams.parameters = parameters
        sdkParams.extraParameters = extraParams
        let sdkViewController: UIViewController = AXTCaptureInterface.captureInterfaceInstance().getViewControllerCaptureSdk(sdkParams)
        self.present(sdkViewController, animated: true, completion: nil)
    }
    
    func getSdkResult(_ notification: Notification) -> Void{
        removeObserversForSDK()
        NSLog("SDK ICHECK.IO send a result")
        let dictionary: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let sdkResult: AXTSdkResult = dictionary.value(forKey: SMARTSDK_RESULT_PARAM) as! AXTSdkResult
        populateViewWithSDKResult(sdkResult)
    }
    
    func smartsdkCrash(_ notification: Notification) -> Void{
        removeObserversForSDK()
        let dictionary: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let exception: NSException = dictionary.value(forKey: SMARTSDK_CRASH) as! NSException
        NSLog("SDK ICHECK.IO send a crash \(exception.reason)")
        UIAlertController(title: "Error", message: exception.reason!, preferredStyle: .alert).show(self, sender: nil)
    }
    
    func smartsdkCancelled() -> Void{
        removeObserversForSDK()
        NSLog("SDK IDCHECK.IO Cancelled by user")
        self.dismiss(animated: true, completion: nil)
    }
    
    func populateViewWithSDKResult(_ sdkResult: AXTSdkResult) {
        if let rectoPath = sdkResult.mapImageCropped.object(forKey: IMAGES_RECTO) as? AXTImageResult {
            recto.image = UIImage(contentsOfFile: rectoPath.imagePath)
        }
        if let versoPath = sdkResult.mapImageCropped.object(forKey: IMAGES_VERSO) as? AXTImageResult {
            verso.image = UIImage(contentsOfFile: versoPath.imagePath)
        }
        if let identityDocument = sdkResult.mapDocument.object(forKey: IDENTITY_DOCUMENT) as? AXTDocumentIdentity {
            data.text = "\(identityDocument.fields.object(forKey: DOCUMENT_NUMBER)!) / \(identityDocument.fields.object(forKey: CODELINE)!) / \(identityDocument.fields.object(forKey: LAST_NAMES)!) / \(identityDocument.fields.object(forKey: FIRST_NAMES)!) / \(identityDocument.fields.object(forKey: BIRTH_DATE)!) / \(identityDocument.fields.object(forKey: EMIT_DATE)!)"
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        NSLog("Force Portrait Orientation")
        var result = UIInterfaceOrientationMask.allButUpsideDown
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            result = UIInterfaceOrientationMask.portrait
        }
        return result
    }

}

