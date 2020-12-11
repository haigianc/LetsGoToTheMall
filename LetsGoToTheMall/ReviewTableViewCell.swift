//
//  ReviewTableViewCell.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/9/20.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewTitle: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet var starImageCollection: [UIImageView]!
    
    var review: Review! {
        didSet{
            reviewTitle.text = review.title
            reviewText.text = review.text
            
            for starImage in starImageCollection {
                let imageName = (starImage.tag < review.rating ? "star.fill" : "star")
                starImage.image = UIImage(systemName: imageName)
                starImage.tintColor = (starImage.tag < review.rating ? UIColor(named: "PrimaryColor") : UIColor(named: "PrimaryColor"))
            }
        }
    }

}
