//
//  ResultViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 01/03/2021.
//

import UIKit
import IDCheckIOSDK


struct ResultEntry {
    let title: String
    let value: String
}

class ResultViewMoodel {
    
    internal init(result: IdcheckioResult?) {
        self.result = result
    }
    
    var result: IdcheckioResult?
    var resultEntries: [ResultEntry] {
        switch result?.document {
        case .identity(let idDocument):
            let documentFields = idDocument.fields.sorted { $0.key.rawValue < $1.key.rawValue }
            let keys = documentFields.map{ $0.key }
            let fields = documentFields.map { $0.value }
            var resultEntries = keys.indices.map { index in
                ResultEntry(title: keys[index].rawValue, value: fields[index].value ?? "")
            }
            resultEntries.removeAll(where: {$0.title == IdentityDocument.Fields.codeLine.rawValue})
            return resultEntries
        case .vehicleRegistration(let registrationDocument):
            let documentFields = registrationDocument.fields.sorted { $0.key.rawValue < $1.key.rawValue }
            let keys = documentFields.map{ $0.key }
            let fields = documentFields.map { $0.value }
            return keys.indices.map { index in
                ResultEntry(title: keys[index].rawValue, value: fields[index].value ?? "")
            }
        default:
            return []
        }
    }
}

class ResultViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak private var pagerScrollView: UIScrollView! {
        didSet {
            pagerScrollView.layer.borderWidth = 2.0
            pagerScrollView.layer.borderColor = UIColor(named: "BlueAriadnext")?.cgColor
            pagerScrollView.isPagingEnabled = true
            pagerScrollView.showsHorizontalScrollIndicator = false
            pagerScrollView.delegate = self
        }
    }

    @IBOutlet weak private var pagerContainerView: UIView!
    @IBOutlet weak private var pagerStackView: UIStackView!
    @IBOutlet weak private var pageControl: UIPageControl! {
        didSet {
            pageControl.pageIndicatorTintColor = UIColor(named: "BlueAriadnext")?.withAlphaComponent(0.2)
            pageControl.currentPageIndicatorTintColor = UIColor(named: "BlueAriadnext")
        }
    }
    @IBOutlet private weak var mainTableView: UITableView! {
        didSet {
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.tableFooterView = UIView() // Remove extra empty cell separators
        }
    }
    
    static let identifier: String = "ResultViewController"
    var numberOfPage: Int = 0 {
        didSet {
            pageControl.numberOfPages = numberOfPage
        }
    }
    var viewModel: ResultViewMoodel?

    override func viewDidLoad() {
        super.viewDidLoad()
        fill()
    }

    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func fill() {
        guard let vm = viewModel, let result = vm.result else { return }
        loadPager(with: result.images)
        mainTableView.reloadData()
        var backgroundView: UIView?
        if vm.resultEntries.isEmpty {
            let label = UILabel()
            label.textColor = .black
            label.textAlignment = .center

            backgroundView = label
        }
        mainTableView.backgroundView = backgroundView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let images = viewModel?.result?.images {
            loadPager(with: images)
        }
    }
}

extension ResultViewController {
    func addImagetoPager(with image: UIImage) {
        numberOfPage += 1
        let imageView = UIImageView()
        imageView.widthAnchor.constraint(equalToConstant: pagerScrollView.bounds.width).isActive = true
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        pagerStackView.addArrangedSubview(imageView)
    }

    func loadPager(with images: [ImageResult]) {
        numberOfPage = 0
        pagerStackView.removeAllArrangedSubviews()
        images.forEach { (image) in
            if let cropped = image.cropped, let imageCropped = UIImage(contentsOfFile: cropped) {
                addImagetoPager(with: imageCropped)
            }
            if let imageSource = UIImage(contentsOfFile: image.source) {
                addImagetoPager(with: imageSource)
            }
            if let face = image.face, let imageFace = UIImage(contentsOfFile: face) {
                addImagetoPager(with: imageFace)
            }
        }
        pageControl.currentPage = 0
    }
}

// MARK: - UIScrollViewDelegate
extension ResultViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(round(value))
    }
}


// MARK: - UITableViewDataSource
extension ResultViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.resultEntries.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = mainTableView.dequeueReusableCell(withIdentifier: ResultEntryCell.identifier, for: indexPath) as? ResultEntryCell else {
            fatalError("Unable to load cell with identifier: \(ResultEntryCell.identifier)")
        }
        cell.resultEntry = viewModel?.resultEntries[indexPath.row]
        return cell
    }
}

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

