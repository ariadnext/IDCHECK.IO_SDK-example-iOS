//
//  DisplayInfoViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 22/02/2021.
//

import UIKit
import IDCheckIOSDK

class DisplayInfoViewModel {
    
    var documentType: String?
    var dataFields: [String: String]?
    var versoSkipable: Bool?
    var sourceImage: String?
    var faceImage: String?
}

protocol DisplayInfoViewControllerDelegate: AnyObject {
    func confirmDidTap()
    func cancelDidTap()
}

class DisplayInfoViewController: UIViewController {

    @IBOutlet private weak var confirmButton: UIButton! {
        didSet {
            confirmButton.layer.borderWidth = 3.0
            confirmButton.layer.borderColor = UIColor(named: "BlueAriadnext")?.cgColor
            confirmButton.setTitle("CONFIRM", for: .normal)
            confirmButton.setTitleColor(UIColor(named: "BlueAriadnext"), for: .normal)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.borderWidth = 3.0
            cancelButton.layer.borderColor = UIColor(named: "BlueAriadnext")?.cgColor
            cancelButton.setTitle("CANCEL", for: .normal)
            cancelButton.setTitleColor(UIColor(named: "BlueAriadnext"), for: .normal)
        }
    }
    
    @IBOutlet private weak var infoTitle: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var infoStackView: UIStackView!

    static let storyboardIdentifier = "DisplayInfoViewControllerIdentifier"
    
    weak var delegate: DisplayInfoViewControllerDelegate?
    
    var viewModel: DisplayInfoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dataFields = viewModel?.dataFields, !dataFields.isEmpty {
            setDataFields(dataFields: dataFields)
        } else if let versoSkipable = viewModel?.versoSkipable {
            setSkipable(skipable: versoSkipable)
        } else if let image = viewModel?.sourceImage {
            infoTitle.text = "Do you want to select this image ?"
            let image = UIImage(contentsOfFile: image)
            let imageView = UIImageView(image: image)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            infoStackView.addArrangedSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: (image?.size.height ?? 0.0) * infoStackView.bounds.width / (image?.size.width ?? 0.0)).isActive = true
        }
    }
    
    @IBAction private func confirmAction(_ sender: Any) {
        delegate?.confirmDidTap()
    }
    
    @IBAction private  func cancelAction(_ sender: Any) {
        delegate?.cancelDidTap()
    }
    
    private func setSkipable(skipable: Bool) {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Please flip your document and press OK to scan the back."
        infoStackView.addArrangedSubview(label)
        infoTitle.text = "Flip your document"
        cancelButton.setTitle("SKIP", for: .normal)
        confirmButton.setTitle("OK", for: .normal)
    }
    
    private func setDataFields(dataFields: [String: String]) {
        guard let dataFields = viewModel?.dataFields else { return }
        infoTitle.text = dataFields[IdentityDocument.Fields.docType.rawValue]
        if let faceImage = viewModel?.faceImage {
            let image = UIImage(contentsOfFile: faceImage)
            let imageView = UIImageView(image: image)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            infoStackView.addArrangedSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        }
        var currentStack: UIStackView?
        for (kind, value) in dataFields {
            guard kind != IdentityDocument.Fields.codeLine.rawValue,  kind != IdentityDocument.Fields.docType.rawValue else { continue }
            if (currentStack?.arrangedSubviews.count ?? 0) % 2 == 0 {
                currentStack = UIStackView()
                currentStack?.axis = .horizontal
                currentStack?.distribution = .fillEqually
                infoStackView.addArrangedSubview(currentStack ?? UIStackView())
            }
            let view = DisplayInfoView()
            view.fill(kind: kind, value: value)
            currentStack?.addArrangedSubview(view)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundCorners(cornerRadius: 20)
    }
    
    private func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = contentView.bounds
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer
    }
}
