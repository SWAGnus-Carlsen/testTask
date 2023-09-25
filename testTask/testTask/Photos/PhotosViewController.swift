//
//  ViewController.swift
//  testTask
//
//  Created by Vitaliy Halai on 24.09.23.
//

import UIKit

final class PhotosViewController: UIViewController {
    
    // MARK: Views

    private lazy var photosTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PhotosTVCell.self, forCellReuseIdentifier: PhotosTVCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: Properties
   
    private var photos: [Photo] = [] {
        didSet {
            photosTableView.reloadData()
        }
    }
    //To fetch correct page
    private var currentPage: Int = 0
    
    //To pass this into POST-request
    private var typeId: Int = -1
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: Private methods

    private func configureUI() {
        title = "List of Photos"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        view.addSubview(photosTableView)
        NSLayoutConstraint.activate([
            photosTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photosTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photosTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
        let activityIndicator = UIActivityIndicatorView()
        footerView.addSubview(activityIndicator)
        activityIndicator.center = footerView.center
        activityIndicator.startAnimating()
        return footerView
    }

    private func fetchPhotosList(forPage page: Int, willPaginating: Bool) {
        APIManager.shared.getPageOfPhotos(pagination: willPaginating, 
                                          from: APIConstants.getPageURL(page)) { [weak self] photoListResponse in
            DispatchQueue.main.async {
                self?.photosTableView.tableFooterView = nil
                self?.photos.append(contentsOf: photoListResponse.content)
            }
        }
    }
    
    private func showImagePicker() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(withTitle: "Something went wrong :// ",
                      withMessage: "Oopss... Camera isn't available on this device")
            print("Oopss... Camera isn't available on this device")
            
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showAlert(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func postPhoto(withImage image: UIImage) {
        APIManager.shared.postPhoto(to: APIConstants.postPhotoURL(), withId: typeId, withImage: image) {
            [weak self] postID in
            DispatchQueue.main.async {
                self?.showAlert(withTitle: "Congratulations!", withMessage: "Photo successfully uploaded. ID: \(postID)")
            }
        }
    }
}

// MARK: - TableViewDataSource extension

extension PhotosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotosTVCell.identifier) as? PhotosTVCell else {
            return UITableViewCell()
        }
        cell.configure(with: PhotosTVCellViewModel(photo: photos[indexPath.row]))
        return cell
    }
}

// MARK: - TableViewDelegate extension

extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        typeId = photos[indexPath.row].id
        showImagePicker()
    }
}

// MARK: - ImagePickerDelegate extension

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
     
        postPhoto(withImage: image)
        
        dismiss(animated: true)
    }
}

// MARK: - ScrollViewDelegate extension

extension PhotosViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (photosTableView.contentSize.height) - scrollView.frame.height - 100 {
            guard !APIManager.isPaginating,
                  currentPage <= 6
            else {
                return
            }
            photosTableView.tableFooterView = createSpinnerFooter()
            
            fetchPhotosList(forPage: currentPage, willPaginating: true)
            
            currentPage += 1
        }
    }
}
