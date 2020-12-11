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
import Firebase

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
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    var store: Store!
    var mall: Mall!
    var malls: Malls!
    var stores: Stores!
    var review: Review!
    var reviews: Reviews!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if malls == nil {
            malls = Malls()
        }
        if reviews == nil {
            reviews = Reviews()
        }
        
        malls.loadData {
            self.updateUserInterface()
        }
        
        stores.loadData(mall: mall) {
            self.tableView.reloadData()
        }
        reviews.loadData(mall: mall, store: store) {
            self.tableView.reloadData()
            if self.reviews.reviewArray.count == 0 {
                self.ratingLabel.text = "-.-"
            } else {
                let sum = self.reviews.reviewArray.reduce(0) { $0 + $1.rating }
                var avgRating = Double(sum)/Double(self.reviews.reviewArray.count)
                avgRating = ((avgRating * 10).rounded())/10
                self.ratingLabel.text = "\(avgRating)"
            }
        }
        operatingHoursTextView.text = ""
        tableView.tableFooterView = UIView()
        //updateUserInterface()
    }
    
    func updateUserInterface(){
        //DispatchQueue.main.async {
        print("🚙 name of store = \(self.store.name)")
        updateNavigationItems()
        self.nameLabel.text = self.store.name
        operatingHoursTextView.text = ""
        for day in 0..<self.store.hours.count{
            print("🕰 \(self.store.hours.count)")
            print("🔁 store hours: \(self.store.hours)")
            self.operatingHoursTextView.text = self.operatingHoursTextView.text + "\(self.store.hours[day])\n"
        }
        
        for dollarImage in self.dollarImageCollection {
            if self.store.priceLevel == -1 {
                dollarImage.image = UIImage()
            } else {
                let imageName = (dollarImage.tag < self.store.priceLevel ? "dollarsign.square.fill" : "dollarsign.square")
                dollarImage.image = UIImage(systemName: imageName)
            }
        }
        
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
    
    func updateNavigationItems(){
        if store.postingUserID == Auth.auth().currentUser?.uid { //same user, save available
            self.navigationItem.leftItemsSupplementBackButton = false
        } else {
            saveBarButtonItem.hide()
            cancelBarButtonItem.hide()
        }
    }
    
    func updateFromInterface() {// update before saving data
        store.name = nameLabel.text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReview" {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ReviewTableViewController
            //destination.review = Review()
            destination.store = store
            destination.mall = mall
        }
        if segue.identifier == "ShowReview" {
            let destination = segue.destination as! ReviewTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[selectedIndexPath.row]
            destination.store = store
            destination.mall = mall
        }
    }
    
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        print("🖥 store.website \(store.website)")
        let url = URL(string: store.website)
        if UIApplication.shared.canOpenURL(url!){
            print("👩‍💻 URL = \(url!)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            print("😡ERROR \(url) cannot be opened")
        }
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
                self.mall.saveData { (success) in
                    if success {
                        self.leaveViewController()
                    } else {
                        self.oneButtonAlert(title: "Failed to Save Mall", message: "For some reason, the data would not save to the cloud")
                    }
                }
                //self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Failed to Save Store", message: "For some reason, the data would not save to the cloud")
            }
        }
        
    }
    
    func saveCancelAlert(title: String, message: String, addingReview: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.store.saveData(mall: self.mall) { (success) in
                self.mall.saveData { (success) in
                    self.saveBarButtonItem.title = "Done"
                    self.cancelBarButtonItem.accessibilityElementsHidden = true
                    self.navigationController?.setToolbarHidden(true, animated: true)
                    //self.disableTextEditing()
                    if addingReview == true {
                        self.performSegue(withIdentifier: "AddReview", sender: nil)
                    }
                }
            }
        }
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        if store.documentID == "" {
            saveCancelAlert(title: "This Store Has Not Been Saved", message: "You must save this store before you can add a review to it.", addingReview: true)
            
        } else {
            performSegue(withIdentifier: "AddReview", sender: nil)
        }
    }
    
    
}

extension StoreDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        //cell.textLabel?.text = reviews.reviewArray[indexPath.row].title
        cell.reviewTitle.text = reviews.reviewArray[indexPath.row].title
        cell.reviewText.text = reviews.reviewArray[indexPath.row].text
        return cell
    }
    
    
}
