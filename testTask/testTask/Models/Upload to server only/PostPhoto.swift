//
//  PostPhoto.swift
//  testTask
//
//  Created by Vitaliy Halai on 25.09.23.
//

import Foundation

struct PostPhoto: Encodable {
    let name: String
    let typeId: Int
    let photo: Data
}
