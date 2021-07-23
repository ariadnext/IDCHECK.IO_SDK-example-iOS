//
//  AdvancedSessionViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 08/02/2021.
//

import UIKit
import IDCheckIOSDK

class AdvancedSessionViewController: UIViewController {

    @IBOutlet weak private var quadView: UIView!
    
    @IBOutlet weak private var cameraButton: UIButton! {
        didSet {
            let cornerRadius: CGFloat = cameraButton.frame.width / 2
            cameraButton.isHidden = true
            cameraButton.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBOutlet weak private var flashButton: UIButton! {
        didSet {
            let cornerRadius: CGFloat = cameraButton.frame.width / 2
            flashButton.isHidden = true
            flashButton.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBOutlet weak private var bottomLabelContainer: UIView! {
        didSet {
            bottomLabelContainer.isHidden = true
        }
    }
    @IBOutlet weak private var informationLabel: UILabel!
    
    static let storyboardIdentifier = "AdvancedSessionViewControllerIdentifier"
    
    weak var coordinator: AdvancedCaptureCoordinator?
    var scenario: SDKScenario?
    
    fileprivate var idcheckioViewController: IdcheckioViewController?
    fileprivate var quadLayer: CAShapeLayer?
    fileprivate var acceptCommand: SDKCommand?
    fileprivate var declineCommand: SDKCommand?
    fileprivate weak var photoCommand: SDKCommand?
    fileprivate weak var flashCommand: SDKCommand?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sdkController = segue.destination as? IdcheckioViewController {
            self.idcheckioViewController = sdkController
            self.prepareSession(controller: sdkController)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Needed when view controller is pushed to manage orientation properly.
        navigationController?.delegate = self
    }
    
    // Let IdcheckioViewController manage orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return idcheckioViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return idcheckioViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
    
    override var shouldAutorotate: Bool {
        return idcheckioViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}

fileprivate extension AdvancedSessionViewController {
    
    func prepareSession(controller: IdcheckioViewController) {
        //Set the prameters for your capture session
        guard let sdkParams = scenario?.config?.sdkParams,
              let sdkExtraParams = scenario?.config?.sdkExtraParams  else {
            coordinator?.showResult(.failure(ConfigError.emptyConfig))
            return
        }
        do {
            try Idcheckio.shared.setParams(sdkParams)
            Idcheckio.shared.extraParameters = sdkExtraParams
        } catch {
            coordinator?.showResult(.failure(error))
            return
        }
        //Manage errors that could occur during SDK startup.
        controller.startCompletion = { [weak self] (error) in
            if let error = error {
                self?.handleSdkResult(result: .failure(error))
            }
        }
        //Set the completion handler for both sdk events and sdk result
        controller.eventCompletion = { [weak self] in self?.handleSdkEvent(interaction: $0, msg: $1) }
        controller.resultCompletion = { [weak self] in self?.handleSdkResult(result: $0) }
        registerInteraction()
    }
    
    func registerInteraction() {
        //Register UI interaction
       Idcheckio.shared.register(for: .ui,
                                  uiMsgs: [ .clear,
                                            .displayMotion,
                                            .showInitialization,
                                            .hideInitialization,
                                            .showLoading,
                                            .hideLoading,
                                            .showZoom,
                                            .showFlash,
                                            .hideFlash,
                                            .pictureInProgress,
                                            .ocrFailed,
                                            .imageBlur,
                                            .imageGlare,
                                            .showScanAnimation,
                                            .hideScanAnimation,
                                            .showManualButton,
                                            .hideManualButton,
                                            .showScanVersoSkippable,
                                            .showScanVersoNonSkippable,
                                            .wrongSide,
                                            .invalidDocument,
                                            .invalidDocType,
                                            .undefined],
                                  override: true)

        //Register quad ineraction
        Idcheckio.shared.register(for: .quad, uiMsgs: nil, override: true)
        //Register the data interaction
        Idcheckio.shared.register(for: .data, uiMsgs: nil, override: true)
        
    }
    
    func handleSdkResult(result: Result<IdcheckioResult?, Error>) {
        coordinator?.showResult(result)
    }
    
    func handleSdkEvent(interaction: IdcheckioInteraction, msg: IdcheckioMsg?) {
        switch interaction {
        case .ui:
            if let msg = msg as? UIMessage {
                handleUiEvent(uiMessage: msg)
            }
        case .quad:
            if let msg = msg as? QuadMessage {
                handleQuadEvent(quadMessage: msg)
            }
        case .data:
            if let msg = msg as? DataMessage {
                handleDataEvent(dataMessage: msg)
            }
        default:
            return
        }
    }
    
    func handleDataEvent(dataMessage: DataMessage?) {
        guard let msg = dataMessage, let accepteCommand = msg.command(for: .acceptResults), let declineCommand = msg.command(for: .declineResults)  else { return }
        self.acceptCommand = accepteCommand
        self.declineCommand = declineCommand
        //Get data from message
        //The type of returned data is IdcheckioResult
        let data = msg.data
        var dataFields = [String: String]()
        switch data.document {
        case .identity(let id):
            id.fields.forEach { (field, data) in
                dataFields[field.rawValue] = data.value
            }
        case .vehicleRegistration(let vehicleRegistration):
            vehicleRegistration.fields.forEach { (field, data) in
                dataFields[field.rawValue] = data.value
            }
        default:
            break
        }
        let vm = DisplayInfoViewModel()
        vm.dataFields = dataFields
        let imageResult = data.images.first
        vm.sourceImage = imageResult?.cropped
        vm.faceImage = imageResult?.face
        showInfoController(vm: vm)
    }
    
    func showInfoController(vm: DisplayInfoViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        DispatchQueue.main.async {
            if let vc = storyboard.instantiateViewController(withIdentifier: DisplayInfoViewController.storyboardIdentifier) as? DisplayInfoViewController {
                vc.viewModel = vm
                vc.delegate = self
                vc.modalPresentationStyle = .popover
                self.present(vc, animated: true)
            }
        }
    }
    
    func handleQuadEvent(quadMessage: QuadMessage?) {
        guard let msg = quadMessage else { return }
        if quadMessage?.show == true {
            drawQuad(quad: msg.quad)
        } else {
            removeQuad()
        }
    }
    
    func handleUiEvent(uiMessage: UIMessage?) {
        switch uiMessage?.msg {
        case .clear:
            clear()
        case .displayMotion:
            showInformation(info: "Try to stabilize the device")
        case .showInitialization:
            showInformation(info: "Initialization")
        case .hideInitialization:
            clear()
        case .showLoading:
            showInformation(info: "Loading...")
        case .hideLoading:
            clear()
        case .showZoom:
            showInformation(info: "Please get closer to the document")
        case .showFlash, .hideFlash:
            showFlash(show: uiMessage?.msg == .showFlash)
            flashCommand = uiMessage?.command(for: .toggleFlash)
        case .showManualButton, .hideManualButton:
            showManualButton(show: uiMessage?.msg == .showManualButton)
            photoCommand = uiMessage?.command(for: .takePicture)
        case .pictureInProgress:
            showInformation(info: "Taking picture, please do not move")
        case .ocrFailed:
            showInformation(info: "Please present the side that includes the Machine Readable Zone")
        case .imageBlur:
            showInformation(info: "Blur detected. Wait…")
        case .imageGlare:
            showInformation(info: "Glare detected. Please avoid high luminosity")
        case .showScanAnimation:
            showInformation(info: "Analyse in progress ...")
        case .hideScanAnimation:
            clear()
        case .wrongSide:
            showInformation(info: "Please present the other side of the document")
        case .invalidDocument:
            showInformation(info: "Invalid or illegible document")
        case .invalidDocType:
            showInformation(info: "Rejected document")
        case .showScanVersoSkippable:
            self.acceptCommand = uiMessage?.command(for: .scanVerso)
            self.declineCommand = uiMessage?.command(for: .skipVerso)
            let vm = DisplayInfoViewModel()
            vm.versoSkipable = true
            showInfoController(vm: vm)
        default:
            return
        }
    }
    
    func removeQuad() {
        DispatchQueue.main.async {
            self.quadLayer?.removeFromSuperlayer()
        }
    }
    
    func drawQuad(quad: Quad) {
        let radius: CGFloat = 8.0

        let dotPath = UIBezierPath(arcCenter: CGPoint(x: quad.leftTop.x, y: quad.leftTop.y), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        dotPath.append(UIBezierPath(arcCenter: CGPoint(x: quad.leftBottom.x, y: quad.leftBottom.y), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true))
        dotPath.append(UIBezierPath(arcCenter: CGPoint(x: quad.rightTop.x, y: quad.rightTop.y), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true))
        dotPath.append(UIBezierPath(arcCenter: CGPoint(x: quad.rightBottom.x, y: quad.rightBottom.y), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true))
        
        DispatchQueue.main.async {
            self.quadLayer?.removeFromSuperlayer()
            self.quadLayer = CAShapeLayer()
            self.quadLayer?.path = dotPath.cgPath
            self.quadLayer?.fillColor = UIColor.red.cgColor
            self.quadLayer?.frame = self.quadView.frame
            self.quadView?.layer.addSublayer(self.quadLayer ??  CAShapeLayer())
        }
        
    }
    
    func showFlash(show: Bool) {
        DispatchQueue.main.async {
            self.flashButton.isHidden = !show
        }
    }
    
    func showManualButton(show: Bool) {
        DispatchQueue.main.async {
            self.cameraButton.isHidden = !show
        }
    }
    
    func showInformation(info: String) {
        DispatchQueue.main.async {
            self.informationLabel.text = info
            self.bottomLabelContainer.isHidden = false
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.bottomLabelContainer.isHidden = true
        }
    }

    @IBAction func didTouchFlashButton(sender: Any) {
        flashCommand?.execute()
    }

    @IBAction func didTouchShutterButton(sender: Any) {
        photoCommand?.execute()
    }
}

extension AdvancedSessionViewController: DisplayInfoViewControllerDelegate {
    
    func confirmDidTap() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.acceptCommand?.execute()
            })
        }
    }
    
    func cancelDidTap() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.declineCommand?.execute()
            })
        }
    }
}

extension AdvancedSessionViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return navigationController.topViewController?.supportedInterfaceOrientations ?? supportedInterfaceOrientations
    }
}
