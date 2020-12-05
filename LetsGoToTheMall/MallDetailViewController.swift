//
//  MallDetailViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit

class MallDetailViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    var mall: Mall!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mall == nil {
            mall = Mall()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() { // update when we arrive with new data
        nameTextField.text = mall.name
        addressTextField.text = mall.address
    }
    
    func updateFromInterface() {// update before saving data
        mall.name = nameTextField.text!
        mall.address = addressTextField.text!
    }
    
    func leaveViewController(){
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
        mall.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud")
            }
        }
    }
    
    @IBAction func findButtonPressed(_ sender: Any) {
    }
    
    
}
