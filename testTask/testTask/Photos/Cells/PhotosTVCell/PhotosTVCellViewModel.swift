//
//  PhotosTVCellViewModel.swift
//  testTask
//
//  Created by Vitaliy Halai on 25.09.23.
//

import Foundation

struct PhotosTVCellViewModel {
    
    let id: Int
    let title: String
    let imageURL: URL?
    
    
    init(photo: Photo) {
        title = photo.name
        id = photo.id
        imageURL = URL(string: photo.image ?? "") //  URL(string: "https://junior.balinasoft.com/images/type/18.jpg")
    }
}
