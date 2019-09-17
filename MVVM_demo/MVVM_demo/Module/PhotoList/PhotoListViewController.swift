//
//  ViewController.swift
//  MVVM_demo
//
//  Created by Nguyen Trong Triet on 9/17/19.
//  Copyright © 2019 Nguyen Trong Triet. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoListViewController: UIViewController {
    
    @IBOutlet var mIndicator: UIActivityIndicatorView!
    @IBOutlet var mTableView: UITableView!
    
    lazy var viewModel: PhotoListViewModel = {
       return PhotoListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initViewModel()
        
    }

    fileprivate func initView() {
        self.navigationItem.title = "Popular"
        
        mTableView.estimatedRowHeight = 150
        mTableView.rowHeight = UITableView.automaticDimension
    }
    
    fileprivate func initViewModel() {
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(message)
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.mIndicator.startAnimating()
                    self?.mTableView.isHidden = true
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.mTableView.alpha = 0.0
                    })
                } else {
                    self?.mIndicator.stopAnimating()
                    self?.mIndicator.isHidden = true
                    self?.mTableView.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.mTableView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.mTableView.reloadData()
            }
        }
        
        viewModel.initFetch()
    }
    
    fileprivate func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension PhotoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCellIdentifier", for: indexPath) as? PhotoListTableViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        cell.photoListCellViewModel = cellVM
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension PhotoListViewController {
  
}

class PhotoListTableViewCell: UITableViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desContainerHeightConstraint: NSLayoutConstraint!
    
    var photoListCellViewModel: PhotoListCellViewModel? {
        didSet {
            nameLabel.text = photoListCellViewModel?.titleText
            descriptionLabel.text = photoListCellViewModel?.descText
            mainImageView?.sd_setImage(with: URL(string:photoListCellViewModel?.imageUrl ?? "" ), completed: nil)
            dateLabel.text = photoListCellViewModel?.dateText
            
        }
    }
}
