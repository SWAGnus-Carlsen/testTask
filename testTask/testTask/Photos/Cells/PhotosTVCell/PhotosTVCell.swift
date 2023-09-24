//
//  PhotosTVCell.swift
//  testTask
//
//  Created by Vitaliy Halai on 24.09.23.
//

import UIKit
import SDWebImage

final class PhotosTVCell: UITableViewCell {
    
    static let identifier = String(describing: PhotosTVCell.self)
    
    // MARK: Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure
    
    
    func configure(with viewModel: PhotosTVCellViewModel) {
        
//        photoImageView.sd_setImage(with: viewModel.imageURL)
        titleLabel.text = viewModel.title
        photoImageView.sd_setImage(
            with: viewModel.imageURL,
            placeholderImage: UIImage(systemName: "camera"),
            options: .avoidAutoCancelImage,
            completed: { [weak self] _,_,_,_ in
                self?.activityIndicator.stopAnimating()
        })
        
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        contentView.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 60),
            photoImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        photoImageView.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])

        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
