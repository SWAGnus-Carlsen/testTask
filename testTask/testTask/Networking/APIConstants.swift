//
//  APIConstants.swift
//  testTask
//
//  Created by Vitaliy Halai on 24.09.23.
//

import Foundation

struct APIConstants {
    
    static func getPageURL(_ numberOfPage: Int) -> URL {
        let urlString = "https://junior.balinasoft.com/api/v2/photo/type?page=\(numberOfPage)"
        guard let url = URL(string: urlString) else {
            return URL(fileURLWithPath: "")
        }
        return url
    }
    
    static func postPhotoURL() -> URL {
        let urlString = "https://junior.balinasoft.com/api/v2/photo"
        guard let url = URL(string: urlString) else {
            return URL(fileURLWithPath: "")
        }
        return url
    }
}
