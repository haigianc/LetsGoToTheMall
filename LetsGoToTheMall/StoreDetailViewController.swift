//
//  StoreDetailViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import Contacts

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .full
    return dateFormatter
}()

class StoreDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var isOpenLabel: UILabel!
    @IBOutlet weak var operatingHoursTextView: UITextView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet var dollarImageCollection: [UIImageView]!
    
    var store: Store!
    var mall: Mall!
    let regionDistance: CLLocationDegrees = 100
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if store == nil {
            store = Store()
        }
        if mall == nil {
            mall = Mall()
        }
        updateUserInterface()
    }
    
    
    
    func updateUserInterface(){
        guard store.name != nil else {
            nameLabel.text = mall.name
            return
        }
        nameLabel.text = store.name
        guard store.hours.weekdayText != nil else {
            operatingHoursTextView.text = "Hours unknown"
            return
        }
        print("🕰 HOURS: \(store.hours.weekdayText![0])")
        operatingHoursTextView.text = "\(store.hours.weekdayText![0])\n \(store.hours.weekdayText![1])\n\(store.hours.weekdayText![2])\n\(store.hours.weekdayText![3])\n\(store.hours.weekdayText![4])\n\(store.hours.weekdayText![5])\n\(store.hours.weekdayText![6])"
        configureIsOpenLabel()
        for dollarImage in dollarImageCollection {
            let imageName = (dollarImage.tag < store.priceLevel.rawValue ? "dollarsign.square.fill" : "dollarsign.square")
            dollarImage.image = UIImage(systemName: imageName)
            //dollarImage.tintColor = (dollarImage.tag < store.priceLevel.rawValue ? .systemRed : .darkText)
        }
    }
    
    func configureIsOpenLabel() {
        if store.isOpen == .open {
            isOpenLabel.textColor = UIColor.green
            isOpenLabel.text = "OPEN NOW"
        } else if store.isOpen == .closed {
            isOpenLabel.textColor = UIColor.red
            isOpenLabel.text = "CLOSED"
        } else {
            isOpenLabel.textColor = UIColor.darkGray
            isOpenLabel.text = ""
        }
    }
    
    func updateFromInterface() {// update before saving data
        store.name = nameLabel.text!
    }
    
    
    
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        //figure out how to open the WEB
    }
    
    
}
