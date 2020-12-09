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
import SafariServices

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
    var stores: Stores!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if store == nil {
            store = Store()
        }
        if mall == nil {
            mall = Mall()
        }
        if stores == nil {
            stores = Stores()
        }
        operatingHoursTextView.text = ""
        //updateUserInterface()
    }
    
    func updateUserInterface(){
        DispatchQueue.main.async {
            print("🚙 name of store = \(self.store.name)")
            //self.nameLabel.text = self.store.name
            self.configureNameLabel()
            self.configureHours()
            self.configurePriceLevel()
            self.configureIsOpenLabel()
        }
    }
    
    func configureNameLabel() {
        DispatchQueue.main.async {
            self.nameLabel.text = self.store.name
        }
    }
    
    func configureHours(){
        DispatchQueue.main.async {
            for day in 0..<self.store.hours.count{
                print("🕰 \(self.store.hours.count)")
                print("🔁 store hours: \(self.store.hours)")
                self.operatingHoursTextView.text = self.operatingHoursTextView.text + "\(self.store.hours[day])\n"
            }
        }
    }
    
    func configurePriceLevel(){
        DispatchQueue.main.async {
            for dollarImage in self.dollarImageCollection {
                if self.store.priceLevel == -1 {
                    dollarImage.image = UIImage()
                } else {
                    let imageName = (dollarImage.tag < self.store.priceLevel ? "dollarsign.square.fill" : "dollarsign.square")
                    dollarImage.image = UIImage(systemName: imageName)
                }
            }
        }
    }
    
    func configureIsOpenLabel() {
        var openValue: GMSPlaceOpenStatus!
        DispatchQueue.main.async {
            openValue = GMSPlaceOpenStatus(rawValue: self.store.isOpen)
            if openValue.rawValue == 1 {
                self.isOpenLabel.textColor = UIColor.green
                self.isOpenLabel.text = "OPEN"
            } else if openValue.rawValue == 2 {
                self.isOpenLabel.textColor = UIColor.red
                self.isOpenLabel.text = "CLOSED"
            } else {
                self.isOpenLabel.textColor = UIColor.darkGray
                self.isOpenLabel.text = ""
            }
        }
    }
    
    func updateFromInterface() {// update before saving data
        store.name = nameLabel.text!
    }
    
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        //let url = URL(string: store.website)!
        
        //UIApplication.shared.open(check as URL, options: [:], completionHandler: nil)
        //UIApplication.shared.open(url, options: [:], completionHandler: nil)
        print("🖥 store.website \(store.website)")
        let url = URL(string: store.website)
        if UIApplication.shared.canOpenURL(url!){
            print("👩‍💻 URL = \(url!)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            print("😡ERROR \(url) cannot be opened")
        }
        //let svc = SFSafariViewController(url: url)
       // present(svc, animated: true, completion: nil)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        } else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        store.saveData(mall: mall) { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Failed to Save Store", message: "For some reason, the data would not save to the cloud")
            }
        }
        mall.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Failed to Save Mall", message: "For some reason, the data would not save to the cloud")
            }
        }
    }
    
    
}
