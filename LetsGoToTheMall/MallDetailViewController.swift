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

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .full
    return dateFormatter
}()

class MallDetailViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var operatingHoursTextView: UITextView!
    @IBOutlet weak var isOpenLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var matchingItems: [MKMapItem] = []

    var mall: Mall!
    var store: Store!
    var stores: Stores!
    let regionDistance: CLLocationDegrees = 600.0
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        if mall == nil {
            mall = Mall()
        }
        
        mapView.delegate = self
        setupMapView()
        updateUserInterface()
    }
    
    func setupMapView(){
        //        print("**** VIEWPORT: \(mall.viewport) is VALID? \(mall.viewport.isValid)")
        //        guard mall.viewport.isValid else {
        //            mapView.setRegion(MKCoordinateRegion(center: mall.coordinate, latitudinalMeters: 600, longitudinalMeters: 600), animated: true)
        //            print("🗺 REGION: \(MKCoordinateRegion(center: mall.coordinate, latitudinalMeters: 600, longitudinalMeters: 600))")
        //            return
        //        }
        //        let northEast = mall.viewport.northEast
        //        let southWest = mall.viewport.southWest
        //        let latitudeDistance: CLLocationDistance = abs(northEast.latitude - southWest.latitude)
        //        let longitudeDistance: CLLocationDistance = abs(northEast.longitude - southWest.longitude)
        //        let region = MKCoordinateRegion(center: mall.coordinate, latitudinalMeters: latitudeDistance, longitudinalMeters: longitudeDistance)
        let region = MKCoordinateRegion(center: mall.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
    }
    
    func updateMap(){
        
        //TODO: need more here to add buttons for clicking each store...
        //mapView.removeAnnotations(mapView.annotations)
        print("*** ANNOTATIONS DESCRIP: \(mapView.annotations.description)")
        print("*** ANNOTATIONS: \(mapView.annotations)")
        mapView.addAnnotation(mall)
        print("*** ANNOTATIONS DESCRIP AFTER MALL : \(mapView.annotations.description)")
        print("*** ANNOTATIONS AFTER MALL : \(mapView.annotations)")
        mapView.setCenter(mall.coordinate, animated: true)
    }
    
    func updateUserInterface() { // update when we arrive with new data
        nameTextField.text = mall.name
        addressTextField.text = mall.address
        guard mall.hours.weekdayText != nil else {
            operatingHoursTextView.text = "Hours unknown"
            return
        }
        print("🕰 HOURS: \(mall.hours.weekdayText![0])")
        operatingHoursTextView.text = "\(mall.hours.weekdayText![0])\n \(mall.hours.weekdayText![1])\n\(mall.hours.weekdayText![2])\n\(mall.hours.weekdayText![3])\n\(mall.hours.weekdayText![4])\n\(mall.hours.weekdayText![5])\n\(mall.hours.weekdayText![6])"
        configureIsOpenLabel()
        updateMap()
    }
    
    func configureIsOpenLabel() {
        if mall.isOpen == .open {
            isOpenLabel.textColor = UIColor.green
            isOpenLabel.text = "OPEN NOW"
        } else if mall.isOpen == .closed {
            isOpenLabel.textColor = UIColor.red
            isOpenLabel.text = "CLOSED"
        } else {
            isOpenLabel.textColor = UIColor.darkGray
            isOpenLabel.text = ""
        }
    }
    
    func getStores(){
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = "Groceries"
//        request.region = mapView.region
//
//        let search = MKLocalSearch(request: request)
//            search.start(completionHandler: {(response, error) in
//                if error != nil {
//                    print("Error occured in search: \(error!.localizedDescription)")
//                } else if response!.mapItems.count == 0 {
//                    print("No matches found")
//                } else {
//                    print("Matches found")
//
//                    for item in response!.mapItems {
//                        print("Name = \(item.name)")
//                        print("Phone = \(item.phoneNumber)")
//                }
//            }
//        })
    }
    
    func updateFromInterface() {// update before saving data
        mall.name = nameTextField.text!
        mall.address = addressTextField.text!
        
        //        var hours = operatingHoursTextView.text
        //        var dailyHours: [String] = []
        //        var dailyString = ""
        //        guard hours != nil else {
        //            return
        //        }
        //        while hours!.contains("\n") {
        //            var indexOf = hours!.firstIndex(of: "\n")
        //            dailyString = hours!.substring(to: indexOf!)
        //            dailyHours.append(dailyString)
        //            var nextIndex = hours!.index(after: indexOf!)
        //            hours = hours!.substring(from: nextIndex)
        //        }
        //        //mall.hours.weekdayText = dailyHours
        //        mall.hours = GMSOpeningHours()
        //        print("***** updated FROM hours = \(mall.hours)")
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
    
    @IBAction func findButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStoreDetail"{
            let destination = segue.destination as! StoreDetailViewController
            destination.store = store
        }
    }
    
}

extension MallDetailViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        mall.name = place.name ?? "Unknown Place"
        mall.address = place.formattedAddress ?? "Unknown Address"
        mall.coordinate = place.coordinate
        //mall.viewport = place.viewport ?? GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 40.74141555000001, longitude: -73.61084819999998), coordinate: CLLocationCoordinate2D(latitude: 40.73458814999999, longitude: -73.61585020000001))
        mall.hours = place.openingHours ?? GMSOpeningHours()
        mall.isOpen = place.isOpen(at: mall.date)
        updateUserInterface()
        dismiss(animated: true, completion: nil)
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
            self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}

extension MallDetailViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //right now, this only performs segue if you click on the MALL annotation
        //must create an annotation for every type "store" in the mapview
        //HOW DO I DO THIS
        performSegue(withIdentifier: "ShowStoreDetail", sender: self)
    }


//    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
//        if prediction.types.contains("store") {
//            performSegue(withIdentifier: "ShowStoreDetail", sender: self)
//            return true
//        } else {
//            wasCancelled(viewController)
//            return false
//        }
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
