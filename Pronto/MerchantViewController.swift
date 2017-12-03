//
//  MerchantViewController.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD

class MerchantViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var reviewsTableView: UITableView!
    
    @IBAction func didTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var repository: Repository! = Repository.instance
    var food: Food!
    var restaurant: Restaurant!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = restaurant.name
        addressLabel.text = restaurant.address
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        reviewsTableView.rowHeight = UITableViewAutomaticDimension
        reviewsTableView.estimatedRowHeight = 200
        reviewsTableView.tableFooterView = UIView()
    }

}

extension MerchantViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = restaurant.products[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "product", for: indexPath)
            as! ProductCollectionViewCell
        cell.set(product: product)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return restaurant.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = restaurant.products[indexPath.row]
        let param = CheckoutParam(restaurant: restaurant, product: product)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        repository.checkout(param: param).subscribe(onNext: { (checkoutResp) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let link = URL(string: checkoutResp.checkoutUrl) {
                UIApplication.shared.open(link)
            }
        }, onError: { _ in
            MBProgressHUD.hide(for: self.view, animated: true)
            let alert = UIAlertController(title: "Error", message: "Failed to place order", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
    
}

extension MerchantViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = food.reviews![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "review", for: indexPath)
            as! ReviewTableViewCell
        cell.set(review: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return food.reviews?.count ?? 0
    }
    
}
