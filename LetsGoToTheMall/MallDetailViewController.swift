//
//  MallDetailViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit
import GooglePlaces
import MapKit
import GoogleMaps
import Contacts
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .full
    return dateFormatter
}()

class MallDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var operatingHoursTextView: UITextView!
    @IBOutlet weak var isOpenLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    var mall: Mall!
    var malls: Malls!
    var store: Store!
    var stores: Stores!
    var review: Review!
    var reviews: Reviews!
    let regionDistance: CLLocationDegrees = 600.0
    var locationManager: CLLocationManager!
    var storeCellTapped = false
    var placeSelected: GMSPlace!
    let date = Date()
    var addingStore = false
    var predictionSelected: GMSAutocompletePrediction!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        if mall == nil {
            mall = Mall()
        }
        if malls == nil {
            malls = Malls()
        }
        //TODO: figure out a way to re-determine isOpenStatus from a saved mall
        malls.loadData {
            self.updateUserInterface()
        }
        stores.loadData(mall: mall) {
            self.tableView.reloadData()
        }

        operatingHoursTextView.text = ""
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setupMapView()
        tableView.tableFooterView = UIView()
        //updateUserInterface()
    }
    
    func setupMapView(){
        let region = MKCoordinateRegion(center: mall.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
    }
    
    func updateMap(){
        DispatchQueue.main.async {
            self.mapView.addAnnotation(self.mall)
            self.mapView.setCenter(self.mall.coordinate, animated: true)
        }
    }
    
    func updateUserInterface() { // update when we arrive with new data
        print("\(mall.name)")
        DispatchQueue.main.async {
            self.nameLabel.text = self.mall.name
            self.addressLabel.text = self.mall.address
            guard self.mall.hours != nil else {
                self.operatingHoursTextView.text = "Hours unknown"
                return
            }
            for x in 0..<self.mall.hours.count {
                self.operatingHoursTextView.text = self.operatingHoursTextView.text + "\(self.mall.hours[x])\n"
            }
        }
        updateNavigationItems()
        configureIsOpenLabel()
        updateMap()
    }
    
    func updateNavigationItems(){
        if mall.userID == "" { //this is a new user
            self.navigationItem.leftItemsSupplementBackButton = false
        } else if mall.userID == Auth.auth().currentUser?.uid { //same user, save available
            self.navigationItem.leftItemsSupplementBackButton = false
        } else {
            saveBarButtonItem.hide()
            cancelBarButtonItem.hide()
        }
    }
    
    func configureIsOpenLabel() {
        let openValue = GMSPlaceOpenStatus(rawValue: mall.isOpen)
        if openValue == .open {
            DispatchQueue.main.async {
                self.isOpenLabel.textColor = UIColor.green
                self.isOpenLabel.text = "OPEN"
            }
            
        } else if openValue == .closed {
            DispatchQueue.main.async {
                self.isOpenLabel.textColor = UIColor.red
                self.isOpenLabel.text = "CLOSED"
            }
            
        } else {
            DispatchQueue.main.async {
                self.isOpenLabel.textColor = UIColor.darkGray
                self.isOpenLabel.text = ""
            }
            
        }
    }
    
    func updateFromInterface() {// update before saving data
        mall.name = nameLabel.text!
        mall.address = addressLabel.text!
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
    
    func saveCancelAlert(title: String, message: String, storeSearch: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.mall.saveData { (success) in
                self.saveBarButtonItem.title = "Done"
                self.cancelBarButtonItem.accessibilityElementsHidden = true
                self.navigationController?.setToolbarHidden(true, animated: true)
                //self.disableTextEditing()
                if storeSearch == true {
                    let autocompleteController = GMSAutocompleteViewController()
                    autocompleteController.delegate = self
                    // Display the autocomplete view controller.
                    self.present(autocompleteController, animated: true, completion: nil)
                }
            }
        }
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addStoreButtonPressed(_ sender: UIBarButtonItem) {
        addingStore = true
        if mall.documentID == "" {
            saveCancelAlert(title: "This Venue Has Not Been Saved", message: "You must save this mall before you can add a store to it.", storeSearch: addingStore)
        } else {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
        }
        storeCellTapped = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStoreDetail" && storeCellTapped == true {
            let destination = segue.destination as! StoreDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            print("🚗 (tapped cell) place from storeArray = \(stores.storeArray[selectedIndexPath.row].name)")
            destination.store = stores.storeArray[selectedIndexPath.row]
            destination.store.name = stores.storeArray[selectedIndexPath.row].name
            destination.store.website = stores.storeArray[selectedIndexPath.row].website
            destination.store.coordinate = stores.storeArray[selectedIndexPath.row].coordinate
            destination.store.averageRating = stores.storeArray[selectedIndexPath.row].averageRating
            destination.store.hours = stores.storeArray[selectedIndexPath.row].hours
            destination.store.priceLevel = stores.storeArray[selectedIndexPath.row].priceLevel
            destination.store.date = date
            destination.store.isOpen = stores.storeArray[selectedIndexPath.row].isOpen
            destination.store.numberOfReviews = stores.storeArray[selectedIndexPath.row].numberOfReviews
            destination.store.postingUserID = mall.userID
            destination.mall = mall
            stores.storeArray.append(store)
            destination.stores = stores
            //destination.updateUserInterface()
            storeCellTapped = false
        } else if segue.identifier == "ShowStoreDetail" && storeCellTapped == false && placeSelected != nil {
            print("🚗 (new place) place from search = \(placeSelected)")
            let destination = segue.destination as! StoreDetailViewController
            let timeIntervalDate = date.timeIntervalSince1970
            var newStore = Store(name: placeSelected.name!, priceLevel: placeSelected.priceLevel.rawValue, website: "\(placeSelected.website!)", coordinate: placeSelected.coordinate, hours: placeSelected.openingHours?.weekdayText ?? ["Unknown"], date: date, isOpen: placeSelected.isOpen().rawValue, averageRating: 0, numberOfReviews: 0, postingUserID: mall.userID, documentID: "")
            destination.store = newStore
            destination.mall = mall
            //destination.updateUserInterface()
            storeCellTapped = false
        }
    }
}

extension MallDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storeCellTapped = true
        print("#️⃣ stores = \(stores.storeArray)")
        return stores.storeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        storeCellTapped = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreInMallTableViewCell
        print("❌ \(store.documentID)")
        cell.store = stores.storeArray[indexPath.row]
        cell.storeNameLabel.text = stores.storeArray[indexPath.row].name
        print("➕ \(store.name) added to tableView list")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        storeCellTapped = true
    }
}

extension MallDetailViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        placeSelected = place
        print("🦄 type store : \(place.types?.contains("store"))")
        print("🦄 type mall : \(place.types?.contains("shopping_mall"))")
        print("🦄 in selected mall : \(mall.viewport.contains(place.coordinate))")
        print("viewport: NE: \(mall.viewport.northEast) SW: \(mall.viewport.southWest)")
        print("store coordinates: \(place.coordinate)")
        if !((place.types?.contains("store") == true || place.types?.contains("shopping_mall") == true) && mall.viewport.contains(place.coordinate)) {
            dismiss(animated: true, completion: nil)
            self.oneButtonAlert(title: "Could not add \(place.name!)", message: "You cannot add a store to a mall that does not contain the store")
        } else {
            storeCellTapped = false
            performSegue(withIdentifier: "ShowStoreDetail", sender: self)
            dismiss(animated: true, completion: nil)
        }
        storeCellTapped = false
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

extension MallDetailViewController: CLLocationManagerDelegate{
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
        
        let currentLocation = locations.last ?? CLLocation()
        print("🗺 Current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        var name = ""
        var address = ""
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if error != nil{
                print("😡😡ERROR: retrieving place. \(error!.localizedDescription)")
            }
            if placemarks != nil{
                //get first palcemark
                let placemark = placemarks?.last
                //assign placemark to locationName
                name = placemark?.name ?? "Name Unknown"
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            }else{
                print("😡😡ERROR: retrieving placemark.")
            }
            //if there is no mall data, make the device location the Mall
            if self.mall.name == "" && self.mall.address == "" {
                self.mall.name = name
                self.mall.address = address
                self.mall.coordinate = currentLocation.coordinate
            }
            self.mapView.userLocation.title = name
            self.mapView.userLocation.subtitle = address.replacingOccurrences(of: "\n", with: ", ")
            //self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}

extension MallDetailViewController: MKMapViewDelegate{
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        //right now, this only performs segue if you click on the MALL annotation
//        print("❌ value of storeCellTapped \(storeCellTapped)")
//        performSegue(withIdentifier: "ShowStoreDetail", sender: self)
//    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            //annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
}
