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
    
    //MARK: Properties
   
    private var photos: [Photo] = [] {
        didSet {
            photosTableView.reloadData()
        }
    }
    
    private var currentPage: Int = 0
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        APIManager.shared.getPageOfPhotos(from: APIConstants.getPageURL(currentPage)) { [weak self] photoListResponse in
            DispatchQueue.main.async {
                self?.photos.append(contentsOf: photoListResponse.content)
            }
        }
        configureUI()
    }
    
    //MARK: Private methods
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
//        if let cell = tableView.cellForRow(at: indexPath) as? PhotosListTableViewCell {
//            viewModel?.send(event: .onShowCamera(photoTypeId: cell.model?.id ?? -1))
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.section == tableView.numberOfSections - 1 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 && !(viewModel?.state.isLastPage ?? true) {
//              viewModel?.send(event: .onLoadMore)
//          }
      }
}

// MARK: - ImagePickerDelegate extension

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
       // viewModel?.send(event: .onPhotoTaken(image))
        self.dismiss(animated: true)
    }
}

// MARK: - ScrollViewDelegate extension
extension PhotosViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let smth = scrollView.frame.height * CGFloat(currentPage + 1)
        if position > (photosTableView.contentSize.height) - scrollView.frame.height - 100 {
            guard !APIManager.isPaginating,
                  currentPage <= 6 else {
                return
            }
            self.photosTableView.tableFooterView = createSpinnerFooter()
            currentPage += 1
            APIManager.shared.getPageOfPhotos(pagination: true, from: APIConstants.getPageURL(currentPage)) { [weak self] photoListResponse in
                
                DispatchQueue.main.async {
                    self?.photosTableView.tableFooterView = nil
                    self?.photos.append(contentsOf: photoListResponse.content)
                }
                
                
            }
        }
        
    }
}