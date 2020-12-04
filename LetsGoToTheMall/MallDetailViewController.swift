//
//  MallDetailViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit

class MallDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    var mall: Mall!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mall == nil {
            mall = Mall()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() { // update when we arrive with new data
        nameLabel.text = mall.name
        addressLabel.text = mall.address
    }
    
    func updateFromInterface() {// update before saving data
        mall.name = nameLabel.text!
        mall.address = addressLabel.text!
    }
    
}
