//
//  StoreInMallTableViewCell.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/8/20.
//

import UIKit

class StoreInMallTableViewCell: UITableViewCell {
    
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeStatusLabel: UILabel!
    
    

    var store: Store! {
        didSet{
            storeNameLabel.text = store.name
            if store.isOpen == 1 {
                storeStatusLabel.textColor = UIColor.green
                storeStatusLabel.text = "OPEN"
            } else if store.isOpen == 2 {
                storeStatusLabel.textColor = UIColor.red
                storeStatusLabel.text = "CLOSED"
            } else {
                storeStatusLabel.textColor = UIColor.darkGray
                storeStatusLabel.text = ""
            }
        }
    }

}
