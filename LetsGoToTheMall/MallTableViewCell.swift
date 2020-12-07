//
//  MallTableViewCell.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit
import CoreLocation

class MallTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var currentLocation: CLLocation!
    
    var mall: Mall!{
        didSet{
            nameLabel.text = mall.name
            guard let currentLocation = currentLocation else{
                distanceLabel.text = "Distance: -.-"
                return
            }
            let distanceInMeters = mall.location.distance(from: currentLocation)
            let distanceInMiles = ((distanceInMeters * 0.00062137) * 10).rounded() / 10
            distanceLabel.text = "Distance: \(distanceInMiles) miles"
        }
    }
}
