//
//  ReviewTableViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/8/20.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class ReviewTableViewController: UITableViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet var starButtonCollection: [UIButton]!
    
    var review: Review!
    var store: Store!
    var mall: Mall!
    
    var rating = 0 {
        didSet {
            for starButton in starButtonCollection {
                let imageName = (starButton.tag < rating ? "star.fill" : "star")
                starButton.setImage(UIImage(systemName: imageName), for: .normal)
                starButton.tintColor = (starButton.tag < rating ? UIColor(named: "PrimaryColor") : UIColor(named: "PrimaryColor"))
            }
            print(">> new rating \(rating)")
            review.rating = rating
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if review == nil {
            review = Review()
        }
        if store == nil {
            store = Store()
        }
        if mall == nil {
            mall = Mall()
        }
        updateUserInterface()
        tableView.tableFooterView = UIView()
    }
    
    func updateUserInterface(){
        DispatchQueue.main.async {
            self.nameLabel.text = self.store.name
            self.reviewTitleField.text = self.review.title
            self.reviewTextView.text = self.review.text
            self.rating = self.review.rating
            self.reviewDateLabel.text = "posted: \(dateFormatter.string(from: self.review.date))"
            if self.review.documentID == "" { //this is a new review
                self.addBordersToEditableObject()
            } else {
                if self.review.reviewUserID == Auth.auth().currentUser?.uid {// review posted by current user
                    self.navigationItem.leftItemsSupplementBackButton = false
                    self.saveBarButton.title = "Update"
                    self.addBordersToEditableObject()
                    self.deleteButton.isHidden = false
                } else { //review posted by a different user
                    self.saveBarButton.hide()
                    self.cancelBarButton.hide()
                    self.postedByLabel.text = "Posted by: \(self.review.reviewUserEmail)"
                    for starButton in self.starButtonCollection {
                        starButton.backgroundColor = .white
                        starButton.isEnabled = false
                    }
                    self.reviewTitleField.isEnabled = false
                    self.reviewTitleField.borderStyle = .none
                    self.reviewTextView.isEditable = false
                    self.reviewTitleField.backgroundColor = .white
                    self.reviewTextView.backgroundColor = .white
                }
            }
        }
    }
    
    func updateFromInterface(){
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
    }
    
    func addBordersToEditableObject(){
        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
        buttonsBackgroundView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        } else{
            navigationController?.popViewController(animated: true)
        }
    }
    

    @IBAction func reviewTitleChanged(_ sender: UITextField) {
        let noSpaces = reviewTitleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    
    @IBAction func reviewTitleDonePressed(_ sender: UITextField) {
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        review.deleteData(mall: mall, store: store, review: review) { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Could not delete review", message: "There was an error deleting your review")
            }
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        review.saveData(mall: mall, store: store) { (success) in
            if success {
                self.store.saveData(mall: self.mall) { (success) in
                    if success {
                        self.mall.saveData { (success) in
                            if success {
                                self.leaveViewController()
                            } else {
                                self.oneButtonAlert(title: "Failed to Save Review to Store in Mall", message: "For some reason, the data would not save to the cloud")
                            }
                        }
                        //self.leaveViewController()
                    } else {
                        self.oneButtonAlert(title: "Failed to Save Review to Store", message: "For some reason, the data would not save to the cloud")
                    }
                }
                //self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Failed to Save Review", message: "For some reason, the data would not save to the cloud")
            }
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
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = sender.tag + 1
    }
    
}
