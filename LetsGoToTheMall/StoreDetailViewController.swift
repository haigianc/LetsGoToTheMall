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
    @IBOutlet weak var tableView: UITableView!
    
    var store: Store!
    var mall: Mall!
    var malls: Malls!
    var stores: Stores!
    var review: Review!
    var reviews: Reviews!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        if store == nil {
            store = Store()
        }
        if mall == nil {
            mall = Mall()
        }
        if stores == nil {
            stores = Stores()
        }
        
        malls.loadData {
            self.updateUserInterface()
        }
        
        stores.loadData(mall: mall) {
            self.tableView.reloadData()
        }
        reviews.loadData(mall: mall, store: store) {
            self.tableView.reloadData()
        }
        operatingHoursTextView.text = ""
        updateUserInterface()
    }
    
    func updateUserInterface(){
        //DispatchQueue.main.async {
            print("🚙 name of store = \(self.store.name)")
            //self.configureNameLabel()
            self.nameLabel.text = self.store.name
            
            //self.configureHours()
            for day in 0..<self.store.hours.count{
                print("🕰 \(self.store.hours.count)")
                print("🔁 store hours: \(self.store.hours)")
                self.operatingHoursTextView.text = self.operatingHoursTextView.text + "\(self.store.hours[day])\n"
            }
            
            //self.configurePriceLevel()
            for dollarImage in self.dollarImageCollection {
                if self.store.priceLevel == -1 {
                    dollarImage.image = UIImage()
                } else {
                    let imageName = (dollarImage.tag < self.store.priceLevel ? "dollarsign.square.fill" : "dollarsign.square")
                    dollarImage.image = UIImage(systemName: imageName)
                }
            }
            
            //self.configureIsOpenLabel()
            var openValue: GMSPlaceOpenStatus!
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
       // }
    }
    
//    func configureNameLabel() {
//        DispatchQueue.main.async {
//            self.nameLabel.text = self.store.name
//        }
//    }
    
//    func configureHours(){
//        DispatchQueue.main.async {
//            for day in 0..<self.store.hours.count{
//                print("🕰 \(self.store.hours.count)")
//                print("🔁 store hours: \(self.store.hours)")
//                self.operatingHoursTextView.text = self.operatingHoursTextView.text + "\(self.store.hours[day])\n"
//            }
//        }
//    }
    
//    func configurePriceLevel(){
//        DispatchQueue.main.async {
//            for dollarImage in self.dollarImageCollection {
//                if self.store.priceLevel == -1 {
//                    dollarImage.image = UIImage()
//                } else {
//                    let imageName = (dollarImage.tag < self.store.priceLevel ? "dollarsign.square.fill" : "dollarsign.square")
//                    dollarImage.image = UIImage(systemName: imageName)
//                }
//            }
//        }
//    }
    
//    func configureIsOpenLabel() {
//        var openValue: GMSPlaceOpenStatus!
//        DispatchQueue.main.async {
//            openValue = GMSPlaceOpenStatus(rawValue: self.store.isOpen)
//            if openValue.rawValue == 1 {
//                self.isOpenLabel.textColor = UIColor.green
//                self.isOpenLabel.text = "OPEN"
//            } else if openValue.rawValue == 2 {
//                self.isOpenLabel.textColor = UIColor.red
//                self.isOpenLabel.text = "CLOSED"
//            } else {
//                self.isOpenLabel.textColor = UIColor.darkGray
//                self.isOpenLabel.text = ""
//            }
//        }
//    }
    
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
    
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        //TODO: eventually check if spot was saved. if it was not saved, save it & segue if save was successful. Otherwise if it was not saved successfully, segue as below:
        performSegue(withIdentifier: "AddReview", sender: nil)
    }
    
    
}

extension StoreDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        cell.textLabel?.text = reviews.reviewArray[indexPath.row].title
        return cell
    }
    
    
}
