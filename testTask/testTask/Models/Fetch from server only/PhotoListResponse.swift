//
//  PhotoListResponse.swift
//  testTask
//
//  Created by Vitaliy Halai on 25.09.23.
//

import Foundation

struct PhotoListResponse: Decodable {
    var page: Int
    var pageSize: Int
    var totalElements: Int
    var totalPages: Int
    var content: [Photo]
}
