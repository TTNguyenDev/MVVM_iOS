//
//  Service.swift
//  MVVM_demo
//
//  Created by Nguyen Trong Triet on 9/17/19.
//  Copyright © 2019 Nguyen Trong Triet. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overload"
    case permissionDenied = "You don't have permission"
}

protocol APIServiceProtocol {
    func fetchPopularPhoto(complete: @escaping (_ success: Bool, _ photos: [Photo], _ error: APIError?) -> ())
}

class APIService: APIServiceProtocol {
    func fetchPopularPhoto(complete: @escaping (Bool, [Photo], APIError?) -> ()) {
        DispatchQueue.global().async {
            sleep(1)
            let path = Bundle.main.path(forResource: "content", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try! decoder.decode(Photos.self, from: data)
            complete(true, photos.photos, nil)
            
        }
    }
}
