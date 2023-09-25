//
//  APIManager.swift
//  testTask
//
//  Created by Vitaliy Halai on 24.09.23.
//


import UIKit

final class APIManager {
    
    //MARK: Singleton
    
    static let shared = APIManager()
    private init() {}
    
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
                if pagination {
                    APIManager.isPaginating = false
                }
                
            } catch {
                print("failed to convert in function \(#function):/n \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func postPhoto(to URL: URL, withName name: String = "Vitaliy Halai", withId id: Int, withImage image: UIImage, completion: @escaping (String) -> Void) {
        guard let photoToSend = image.jpegData(compressionQuality: 1.0) else {
            print("Photo converting error")
            return
        }
        
        let photoData = PostPhoto(name: name, typeId: id, photo: photoToSend)
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
        
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        httpBody.append("\(photoData.typeId)\r\n".data(using: .utf8)!)
        
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        httpBody.append("\(photoData.name)\r\n".data(using: .utf8)!)
        
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpeg\"\r\n".data(using: .utf8)!)
        httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        httpBody.append(photoData.photo)
        httpBody.append("\r\n".data(using: .utf8)!)
        
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody as Data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Error occured while sending POST request: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return }
            
            guard let data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let responseDict = json as? [String: String],
                      let id = responseDict["id"] else { return }
                completion(id)
                
            } catch {
                print("failed to convert in function \(#function):/n \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    
}
