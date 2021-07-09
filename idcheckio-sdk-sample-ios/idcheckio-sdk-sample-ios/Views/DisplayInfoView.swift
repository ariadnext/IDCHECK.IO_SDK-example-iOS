//
//  DisplayInfoView.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 22/02/2021.
//

import UIKit

class DisplayInfoView: UIView {
    
    @IBOutlet weak private var value: UILabel!
    @IBOutlet weak private var kind: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
    
    func loadFromNib() {
        if let view: UIView = Bundle(for: DisplayInfoView.self).loadNibNamed("DisplayInfoView", owner: self, options: nil)?[0] as? UIView {
            self.addSubview(view)
            addConstraint(view: view)
        }
    }
    
    func fill(kind: String, value: String) {
        self.kind.text = kind
        self.value.text = value
    }
    
    fileprivate func addConstraint(view: UIView) {
            view.translatesAutoresizingMaskIntoConstraints = false
            [self.topAnchor.constraint(equalTo: view.topAnchor),
             self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             self.bottomAnchor.constraint(equalTo: view.bottomAnchor)].forEach{ $0.isActive = true }
    }
    
}
