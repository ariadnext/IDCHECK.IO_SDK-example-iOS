//
//  ResultViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 01/03/2021.
//

import UIKit
import IDCheckIOSDK

class ResultViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak private var pagerScrollView: UIScrollView! {
        didSet {
            pagerScrollView.isPagingEnabled = true
            pagerScrollView.showsHorizontalScrollIndicator = false
            pagerScrollView.delegate = self
        }
    }

    @IBOutlet weak private var pagerContainerView: UIView!
    @IBOutlet weak private var pagerStackView: UIStackView!
    @IBOutlet weak private var pageControl: UIPageControl! {
        didSet {
            pageControl.pageIndicatorTintColor =  UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 0.2)
            pageControl.currentPageIndicatorTintColor =  UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 1)
        }
    }
    @IBOutlet private weak var mainTableView: UITableView! {
        didSet {
            mainTableView.delegate = self
            mainTableView.dataSource = self
            mainTableView.tableFooterView = UIView() // Remove extra empty cell separators
        }
    }

    // MARK: - Properties
    var numberOfPage: Int = 0 {
        didSet {
            pageControl.numberOfPages = numberOfPage
        }
    }
    var viewModel: ResultViewModel?

    static let identifier: String = "ResultViewController"

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.906, green: 0.361, blue: 0.2, alpha: 1)
        fill()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let images = viewModel?.result?.images {
            loadPager(with: images)
        }
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

// MARK: - Private methods
private extension ResultViewController {
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
