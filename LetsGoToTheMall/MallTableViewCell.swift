//
//  MallTableViewCell.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit

class MallTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var mall: Mall!{
        didSet{
            nameLabel.text = mall.name
            
        }
    }
}
