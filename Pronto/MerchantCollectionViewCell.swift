//
//  MerchantCollectionViewCell.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit
import Kingfisher

class MerchantCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var merchantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ubpImageView: UIImageView!
    
    func set(restaurant: Restaurant) {
        nameLabel.text = restaurant.name
        addressLabel.text = restaurant.address
        ratingLabel.text = "⭐️⭐️⭐️⭐️⭐️"
        let url = URL(string: restaurant.image)
        merchantImageView.kf.setImage(with: url)
        ubpImageView.isHidden = !restaurant.isProntoMerchant
    }
    
}
