//
//  Photo.swift
//  testTask
//
//  Created by Vitaliy Halai on 25.09.23.
//

import Foundation

struct Photo: Decodable {
    var id: Int
    var name: String
    var image: String?
}
