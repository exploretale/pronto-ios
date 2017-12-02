//
//  ReviewTableViewCell.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var starRatingLabel: UILabel!
    
    func set(review: Review) {
        titleLabel.text = review.title
        bodyLabel.text = review.body
        var star = ""
        if let rating = review.rating {
            for _ in 1...rating {
                star += "⭐️"
            }
            starRatingLabel.text = star
        } else {
            starRatingLabel.text = ""
        }
    }
    
}
