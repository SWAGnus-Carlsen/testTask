//
//  APIManager.swift
//  testTask
//
//  Created by Vitaliy Halai on 24.09.23.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    private init(){}
    
    static var isPaginating = false
    
    func getPageOfPhotos(pagination: Bool = false, from URL: URL, completion: @escaping (PhotoListResponse) -> Void) {
        
        if pagination {
            APIManager.isPaginating = true
        }
        
        let request = URLRequest(url: URL)
       
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil else { return }
            
            do {
                let dataFromJson = try JSONDecoder().decode(PhotoListResponse.self, from: data)
                completion(dataFromJson)
                print(dataFromJson)
                if pagination {
                    APIManager.isPaginating = false
                }
                
            } catch {
                print("failed to convert in function \(#function):/n \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

struct PhotoListResponse: Decodable {
    var page: Int
    var pageSize: Int
    var totalElements: Int
    var totalPages: Int
    var content: [Photo]
}

struct Photo: Decodable {
    var id: Int
    var name: String
    var image: String?
}
