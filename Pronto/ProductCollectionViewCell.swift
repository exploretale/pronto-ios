//
//  ProductCollectionViewCell.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func set(product: Product) {
        nameLabel.text = product.name
        priceLabel.text = "PHP " + product.price
        if let img = product.image, let url = URL(string: img) {
            productImageView.kf.setImage(with: url)
        } else {
            productImageView.image = nil
        }
    }
    
}
