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

class MallDetailViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var sundayHours: UITextField!
    @IBOutlet weak var mondayHours: UITextField!
    @IBOutlet weak var tuesdayHours: UITextField!
    @IBOutlet weak var wednesdayHours: UITextField!
    @IBOutlet weak var thursdayHours: UITextField!
    @IBOutlet weak var fridayHours: UITextField!
    @IBOutlet weak var saturdayHours: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var mall: Mall!
    let regionDistance: CLLocationDegrees = 600.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mall == nil {
            mall = Mall()
        }
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
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(mall)
        mapView.setCenter(mall.coordinate, animated: true)
    }
    
    func updateUserInterface() { // update when we arrive with new data
        nameTextField.text = mall.name
        addressTextField.text = mall.address
        print("⏳ mall.hours.periods?[0].openEvent HOUR= \(mall.hours.periods?[0].openEvent.time.hour) MINUTE = \(mall.hours.periods?[0].openEvent.time.minute)")

        sundayHours.text = "\(findHour(day: 0, open: true)):\(findMinute(day: 0, open: true)) - \(findHour(day: 0, open: false)):\(findMinute(day: 0, open: false))"
        mondayHours.text = "\(findHour(day: 1, open: true)):\(findMinute(day: 1, open: true)) - \(findHour(day: 1, open: false)):\(findMinute(day: 1, open: false))"
        tuesdayHours.text = "\(findHour(day: 2, open: true)):\(findMinute(day: 2, open: true)) - \(findHour(day: 2, open: false)):\(findMinute(day: 2, open: false))"
        wednesdayHours.text = "\(findHour(day: 3, open: true)):\(findMinute(day: 3, open: true)) - \(findHour(day: 3, open: false)):\(findMinute(day: 3, open: false))"
        thursdayHours.text = "\(findHour(day: 4, open: true)):\(findMinute(day: 4, open: true)) - \(findHour(day: 4, open: false)):\(findMinute(day: 4, open: false))"
        fridayHours.text = "\(findHour(day: 5, open: true)):\(findMinute(day: 5, open: true)) - \(findHour(day: 5, open: false)):\(findMinute(day: 5, open: false))"
        saturdayHours.text = "\(findHour(day: 6, open: true)):\(findMinute(day: 6, open: true)) - \(findHour(day: 6, open: false)):\(findMinute(day: 6, open: false))"
        updateMap()
    }
    
    func findHour(day: Int, open: Bool) -> String {
        var hour: UInt
        if open {
            hour = mall.hours.periods?[day].openEvent.time.hour ?? UInt()
        } else{
            hour = mall.hours.periods?[day].closeEvent?.time.hour ?? UInt()
        }
        var intHour = Int(hour)
        if intHour > 12 {
            intHour = intHour - 12
            return "\(intHour)"
        } else {
            return "\(intHour)"
        }
    }
        
    func findMinute(day: Int, open: Bool) -> String {
        var minuteString = ""
        var minute: UInt
        if open {
            minute = mall.hours.periods?[day].openEvent.time.minute ?? UInt()
            if Int(mall.hours.periods?[day].openEvent.time.hour ?? UInt()) <= 12 {
                let intMin = Int(minute)
                if intMin == 0 {
                    minuteString = "00 AM"
                } else {
                    minuteString = "\(intMin) AM"
                }
                return minuteString
            }
        } else{
            minute = mall.hours.periods?[day].closeEvent?.time.minute ?? UInt()
            if Int(mall.hours.periods?[day].closeEvent?.time.hour ?? UInt()) > 12 {
                let intMin = Int(minute)
                if intMin == 0 {
                    minuteString = "00 PM"
                } else {
                    minuteString = "\(intMin) PM"
                }
                return minuteString
            }
        }
        return minuteString
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
    
    @IBAction func findButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
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
