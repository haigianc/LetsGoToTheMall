//
//  MallListViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import Contacts
import Firebase

class MallListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var signOutBarButton: UIBarButtonItem!

    let userID = Auth.auth().currentUser?.uid ?? ""
    
    var mall: Mall!
    var malls: Malls!
    var store: Store!
    var stores: Stores!
    var review: Review!
    var reviews: Reviews!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var cellTapped = false
    var placeSelected: GMSPlace!
    var placeID: String! = ""
    let date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mall = Mall()
        malls = Malls()
        store = Store()
        stores = Stores()
        review = Review()
        reviews = Reviews()
        tableView.delegate = self
        tableView.dataSource = self
        configureSegmentedControl()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setToolbarHidden(false, animated: true)
        
        getLocation()
        malls.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("⏩ segue.identifier = \(segue.identifier)")
        if segue.identifier == "ShowMallDetail" && cellTapped == true {
            let destination = segue.destination as! MallDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.mall = malls.mallArray[selectedIndexPath.row]
            destination.mall.name = malls.mallArray[selectedIndexPath.row].name
            destination.mall.address = malls.mallArray[selectedIndexPath.row].address
            destination.mall.coordinate = malls.mallArray[selectedIndexPath.row].coordinate
            destination.mall.viewport = malls.mallArray[selectedIndexPath.row].viewport
            destination.mall.hours = malls.mallArray[selectedIndexPath.row].hours
            destination.mall.isOpen = malls.mallArray[selectedIndexPath.row].isOpen
            //destination.updateUserInterface()
            destination.store = store
            destination.stores = stores
            destination.malls = malls
            destination.review = review
            destination.reviews = reviews
            cellTapped = false
        } else if segue.identifier == "ShowMallDetail" && cellTapped == false && placeSelected != nil {
            let destination = segue.destination as! MallDetailViewController
            let timeIntervalDate = date.timeIntervalSince1970
            var newMall = Mall(name: placeSelected.name!, address: placeSelected.formattedAddress!, coordinate: placeSelected.coordinate, viewport: placeSelected.viewport ?? GMSCoordinateBounds(), hours: placeSelected.openingHours?.weekdayText ?? ["Unknown"], date: date, isOpen: placeSelected.isOpen().rawValue, userID: "", documentID: "")
            destination.mall = newMall
            destination.stores = Stores()
            destination.store = Store()
            destination.review = Review()
            destination.reviews = Reviews()
            //destination.malls = Malls()
            //destination.updateUserInterface()
            cellTapped = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        cellTapped = false
    }
    
    func sortBasedOnSegmentPressed(){
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0: //a-z
            malls.mallArray.sort(by: {$0.name < $1.name})
        case 1: //closest
            malls.mallArray.sort(by: {$0.location.distance(from: currentLocation) < $1.location.distance(from: currentLocation) })
        default:
            print("HEY! You shouldn't have gotten here. Check out the segmented control for an error!")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
    
    func editingView() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
            signOutBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
            signOutBarButton.isEnabled = false
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        editingView()
    }
    
    
}

extension MallListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return malls.mallArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapped = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MallTableViewCell
        if let currentLocation = currentLocation {
            cell.currentLocation = currentLocation
        }
        cellTapped = true
        cell.mall = malls.mallArray[indexPath.row]
        //cell.nameLabel?.text = malls.mallArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && userID == malls.mallArray[indexPath.row].userID {
            mall = malls.mallArray[indexPath.row]
            malls.mallArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            mall.deleteData(mall: mall) { (success) in
                for singleStore in self.stores.storeArray {
                    for singleReview in self.reviews.reviewArray {
                        self.review.deleteData(mall: self.mall, store: singleStore, review: singleReview) { (success) in
                            self.store.deleteData(mall: self.mall, store: singleStore) { (success) in
                                if !success {
                                    self.oneButtonAlert(title: "Could not delete data", message: "There was an error deleting your data")
                                }
                            }
                        }
                        if !success {
                            self.oneButtonAlert(title: "Could not delete data", message: "There was an error deleting your data")
                        }
                    }
                }
                if !success {
                    self.oneButtonAlert(title: "Could not delete data", message: "There was an error deleting your data")
                }
            }
        } else if userID != malls.mallArray[indexPath.row].userID {
            self.oneButtonAlert(title: "Could not delete data", message: "You cannot delete a mall you didn't post.")
        }
    }
    
}

extension MallListViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if !(place.types?.contains("shopping_mall") == true) {
            dismiss(animated: true, completion: nil)
            self.oneButtonAlert(title: "Could not add \(place.name!)", message: "You cannot add \(place.name!) because it is not a mall")
        } else {
            placeSelected = place
            performSegue(withIdentifier: "ShowMallDetail", sender: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension MallListViewController: CLLocationManagerDelegate{
    func getLocation(){
        //Creating a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("👮‍♀️👮‍♀️ Checking Authorization Status.")
        handleAuthenticationStatus(status: status)
    }
    
    func handleAuthenticationStatus(status: CLAuthorizationStatus){
        switch status{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("😡😡 DEVELOPER ALERT: Unknown case of status in handleAuthenitcationStatus\(status)")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last ?? CLLocation()
        print("🗺 Current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        sortBasedOnSegmentPressed()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}
