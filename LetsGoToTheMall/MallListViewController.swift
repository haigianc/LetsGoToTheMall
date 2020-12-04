//
//  MallListViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit

class MallListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var malls = ["Roosevelt Field", "Americana", "The Shops at Chestnut Hill", "Chestnut Hill Square"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureSegmentedControl()
    }
    
    func configureSegmentedControl() {
        //set font colors for segemented control
        let pinkFontColor = [NSAttributedString.Key.foregroundColor : UIColor(named: "PrimaryColor") ?? UIColor.systemPink]
        let lightFontColor = [NSAttributedString.Key.foregroundColor : UIColor(named: "SecondaryColor") ?? UIColor.white]
        sortSegmentedControl.setTitleTextAttributes(pinkFontColor, for: .selected)
        sortSegmentedControl.setTitleTextAttributes(lightFontColor, for: .normal)
        
        //add white border to segmented control
        sortSegmentedControl.layer.borderColor = UIColor(named: "SecondaryColor")?.cgColor //creates UIColor as app's secondary color
        sortSegmentedControl.layer.borderWidth = 1.0
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//
//        // Display the autocomplete view controller.
//        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    
}

extension MallListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return malls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MallTableViewCell
        cell.nameLabel?.text = malls[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
