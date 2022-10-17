//
//  ScenariosViewController.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Arthur Josselin on 26/01/2021.
//

import UIKit
import IDCheckIOSDK

class ScenariosViewController: UIViewController {

    static let identifier = "scenarioVc"
    
    weak var coordinator: ScenariosCoordinator?
    var scenarios: [SDKScenario]?
    
    fileprivate var galleryImages: [UIImage] = []
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    fileprivate var pageIndex: Int = 0 {
        didSet {
            if pageIndex != oldValue {
                pageControl.currentPage = pageIndex
            }
        }
    }
    
    @IBOutlet private weak var appDescription: UILabel! {
        didSet {
            appDescription.text = "This is the official sample of the IDCheck.io SDK, a by-product of IDCheck.io produced by Ariadnext. You will find several examples of sdk integration there, you are free to look at the one that best meets your needs.\n\nWarning, to run this sample you will need a token, for more information you can contact us at the following address: csm@ariadnext.com"
        }
    }
    @IBOutlet private weak var choicesCollectionView: UICollectionView!
    @IBOutlet private weak var startButton: UIButton! {
        didSet {
            startButton.layer.borderWidth = 3.0
            startButton.layer.borderColor = UIColor(named: "BlueAriadnext")?.cgColor
            startButton.setTitle("Give it a try", for: .normal)
            startButton.setTitleColor(UIColor(named: "BlueAriadnext"), for: .normal)
        }
    }
    
    @IBOutlet private weak var pageControl: UIPageControl! {
        didSet {
            pageControl.numberOfPages = scenarios?.count ?? 0
        }
    }
    
    @IBAction private func startAction(_ sender: Any) {
        switch scenarios?[pageIndex].captureType {
        case .analyze:
            loadImagesFromGallery()
        default:
            coordinator?.startScenario(scenarios?[pageIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choicesCollectionView.delegate = self
        choicesCollectionView.dataSource = self
        choicesCollectionView.isPagingEnabled = true
        choicesCollectionView.contentInsetAdjustmentBehavior = .never
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        choicesCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        choicesCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ScenariosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenarios?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellidentifier = "choiceCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellidentifier, for: indexPath) as? ChoiceCollectionViewCell else { fatalError("Unable to load cell for identifier \(cellidentifier)") }
        cell.scenario = scenarios?[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        self.pageIndex = Int(pageIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension ScenariosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    fileprivate func loadImagesFromGallery(secondSide: Bool = false) {
        if !secondSide {
            galleryImages.removeAll()
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Impossible to load images from gallery", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        galleryImages.append(image)
        if galleryImages.count == 1 {
            let alert = UIAlertController(title: "Side 2", message: "Do you want to add a second side", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.coordinator?.analyzeImages((weakSelf.galleryImages[0], nil))
            }))
            alert.addAction(UIAlertAction(title: "yes", style: .default, handler: { [weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.loadImagesFromGallery(secondSide: true)
            }))
            self.present(alert, animated: true)
        } else if galleryImages.count == 2 {
            self.coordinator?.analyzeImages((galleryImages[0], galleryImages[1]))
        }
    }
}

extension ScenariosViewController: ChoiceCollectionViewCellDelegate {
    func didSelectConfig(_ config: SDKConfig, forScenario scenario: SDKScenario) {
        if let index = scenarios?.firstIndex(of: scenario) {
            scenarios?[index].config = config
        }
    }
}
