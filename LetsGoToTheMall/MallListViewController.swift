//
//  MallListViewController.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import UIKit
import CoreLocation

class MallListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mallListSegmentedControll: UISegmentedControl!
    
    var malls: Malls!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        malls = Malls()
        tableView.delegate = self
        tableView.dataSource = self
        configureSegmentedControl()
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
        mallListSegmentedControll.setTitleTextAttributes(pinkFontColor, for: .selected)
        sortSegmentedControl.setTitleTextAttributes(lightFontColor, for: .normal)
        mallListSegmentedControll.setTitleTextAttributes(lightFontColor, for: .normal)
        
        //add white border to segmented control
        sortSegmentedControl.layer.borderColor = UIColor(named: "SecondaryColor")?.cgColor //creates UIColor as app's secondary color
        mallListSegmentedControll.layer.borderColor = UIColor(named: "SecondaryColor")?.cgColor
        sortSegmentedControl.layer.borderWidth = 1.0
        mallListSegmentedControll.layer.borderWidth = 1.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMallDetail" {
            let destination = segue.destination as! MallDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.mall = malls.mallArray[selectedIndexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //        let autocompleteController = GMSAutocompleteViewController()
        //        autocompleteController.delegate = self
        //
        //        // Display the autocomplete view controller.
        //        present(autocompleteController, animated: true, completion: nil)
        
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
}

extension MallListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return malls.mallArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MallTableViewCell
        if let currentLocation = currentLocation {
            cell.currentLocation = currentLocation
        }
        cell.mall = malls.mallArray[indexPath.row]
        //cell.nameLabel?.text = malls.mallArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
