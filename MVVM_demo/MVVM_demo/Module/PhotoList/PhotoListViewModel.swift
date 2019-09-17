//
//  PhotoListViewModel.swift
//  MVVM_demo
//
//  Created by Nguyen Trong Triet on 9/17/19.
//  Copyright © 2019 Nguyen Trong Triet. All rights reserved.
//

import Foundation

class PhotoListViewModel {
    let apiService: APIServiceProtocol
    
    private var photos: [Photo] = [Photo]()
    
    private var cellViewModels: [PhotoListCellViewModel] = [PhotoListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var isAllowSegue: Bool = false
    
    var selectedPhoto: Photo?
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch() {
        apiService.fetchPopularPhoto { [weak self] (success, photos, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processFetchPhoto(photos: photos)
            }
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotoListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel(photo: Photo) -> PhotoListCellViewModel {
        //Wrap a description
        var descTextContainer: [String] = [String]()
        
        if let camera = photo.camera {
            descTextContainer.append(camera)
        }
        
        if let description = photo.description {
            descTextContainer.append(description)
        }
        
        let desc = descTextContainer.joined(separator: " - ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "yyyy-MM-dd"
        
        return PhotoListCellViewModel(titleText: photo.name, descText: desc, imageUrl: photo.image_url, dateText: dateFormatter.string(from: photo.created_at))
    }
    
    private func processFetchPhoto(photos: [Photo]) {
        self.photos = photos //cache
        var vms = [PhotoListCellViewModel]()
        photos.forEach { (photo) in
            vms.append(createCellViewModel(photo: photo))
        }
        self.cellViewModels = vms
    }
}

extension PhotoListViewModel {
    func userPressed(at indexPath: IndexPath) {
        let photo = self.photos[indexPath.row]
        if photo.for_sale {
            self.isAllowSegue = true
            self.selectedPhoto = photo
        } else {
            self.isAllowSegue = false
            self.selectedPhoto = nil
            self.alertMessage = "This item is not for sale"
        }
    }
}

struct PhotoListCellViewModel {
    let titleText: String
    let descText: String
    let imageUrl: String
    let dateText: String
}
