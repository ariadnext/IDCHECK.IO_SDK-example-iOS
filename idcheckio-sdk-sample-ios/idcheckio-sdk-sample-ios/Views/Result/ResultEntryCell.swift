//
//  ResultEntryCell.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Nabil LAHLOU on 31/10/2025.
//

import UIKit

/// Cell displayed in the result view
class ResultEntryCell: UITableViewCell {
    static let identifier = "ResultEntryCellIdentifier"

    // MARK: - Outlets
    @IBOutlet private weak var resultTitleLabel: UILabel! {
        didSet {
            resultTitleLabel.textColor = .lightGray
            resultTitleLabel.backgroundColor = .clear
        }
    }
    @IBOutlet private weak var resultValueLabel: UILabel! {
        didSet {
            resultValueLabel.textColor = .black
        }
    }

    // MARK: - Internal properties
    var resultEntry: ResultEntry? {
        didSet {
            resultTitleLabel?.text = resultEntry?.title
            resultValueLabel?.text = resultEntry?.value
        }
    }
}
