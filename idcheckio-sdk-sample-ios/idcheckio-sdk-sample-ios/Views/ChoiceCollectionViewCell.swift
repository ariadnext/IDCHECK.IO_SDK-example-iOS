//
//  ChoiceCollectionViewCell.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 26/01/2021.
//

import UIKit
import IDCheckIOSDK

protocol ChoiceCollectionViewCellDelegate: AnyObject {
    func didSelectConfig(_ config: SDKConfig, forScenario scenario: SDKScenario)
}

class ChoiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var title: UILabel!
    @IBOutlet weak private var contentDescription: UILabel!
    @IBOutlet weak private var documentPicker: UIPickerView! {
        didSet {
            documentPicker.dataSource = self
            documentPicker.delegate = self
        }
    }
    @IBOutlet weak private var footer: UILabel!

    var scenario: SDKScenario? {
        didSet {
            footer.text = scenario?.captureType.footer
            contentDescription.text = scenario?.captureType.description
            title.text = scenario?.captureType.displayName
            if scenario?.availableConfigs.isEmpty == true {
                documentPicker.isHidden = true
            }
        }
    }
    weak var delegate: ChoiceCollectionViewCellDelegate?
    
    fileprivate var configs: [SDKConfig] {
        return scenario?.availableConfigs ?? []
    }
}

extension ChoiceCollectionViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return configs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return configs[row].rawValue
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.text =  configs[row].rawValue
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let scenario = scenario {
            delegate?.didSelectConfig(configs[row], forScenario: scenario)
        }
    }
}
