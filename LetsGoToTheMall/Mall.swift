//
//  Mall.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase
import MapKit
import GoogleMaps
import GooglePlaces

class Mall: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    //var viewport: GMSCoordinateBounds
    var hours: GMSOpeningHours
    var date: Date
    var isOpen: GMSPlaceOpenStatus
    var userID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        //return ["name": name, "address": address, "viewport": viewport, "userID": userID]
        var timeIntervalDate = date.timeIntervalSince1970
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitutde, "date": timeIntervalDate, "isOpen": isOpen, "userID": userID]
    }
    
    //might have to add enums for isOpen
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitutde: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var closeMinute: Int {
        return Int(closeTime.minute)
    }
    
    var closeHour: Int {
        return Int(closeTime.hour)
    }
    
    var openMinute: Int{
        return Int(openTime.minute)
    }
    
    var openHour: Int{
        return Int(openTime.hour)
    }
    
    var closeTime: GMSTime{
        return closeEvent.time
    }
    
    var openTime: GMSTime{
        return openEvent.time
    }
    
    var closeEvent: GMSEvent{
        return period[0].closeEvent ?? GMSEvent()
    }
    
    var openEvent: GMSEvent{
        return period[0].openEvent
    }
    
    var period: [GMSPeriod] {
        return hours.periods ?? [GMSPeriod()]
    }
    
//    var neLatitude: CLLocationDegrees {
//        return northEast.latitude
//    }
//
//    var neLongitutde: CLLocationDegrees{
//        return northEast.longitude
//    }
//
//    var swLatitude: CLLocationDegrees {
//        return southWest.latitude
//    }
//
//    var swLongitutde: CLLocationDegrees{
//        return southWest.longitude
//    }
//
//    var northEast: CLLocationCoordinate2D{
//        return viewport.northEast
//    }
//
//    var southWest: CLLocationCoordinate2D{
//        return viewport.southWest
//    }
    
    var location: CLLocation{
        return CLLocation(latitude: latitude, longitude: longitutde)
    }
    
    var title: String? {
        return name
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, hours: GMSOpeningHours, date: Date, isOpen: GMSPlaceOpenStatus, userID: String, documentID: String) {
        //add viewport: GMSCoordinateBounds, as a parameter
        self.name = name
        self.address = address
        self.coordinate = coordinate
        //self.viewport = viewport
        self.hours = hours
        self.date = date
        self.isOpen = isOpen
        self.userID = userID
        self.documentID = documentID
    }
    
    convenience override init() {
        //add viewport: GMSCoordinateBounds(), to function call
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), hours: GMSOpeningHours(), date: Date(), isOpen: GMSPlaceOpenStatus(rawValue: 0) ?? GMSPlaceOpenStatus.unknown, userID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let neLatitude = dictionary["neLatitude"] as! Double? ?? 0.0
//        let neLongitude = dictionary["neLongitude"] as! Double? ?? 0.0
//        let swLatitude = dictionary["neLatitude"] as! Double? ?? 0.0
//        let swLongitude = dictionary["neLongitude"] as! Double? ?? 0.0
//        let northEast = CLLocationCoordinate2D(latitude: neLatitude, longitude: neLongitude)
//        let southWest = CLLocationCoordinate2D(latitude: swLatitude, longitude: swLongitude)
//        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
//        let closeMinute = dictionary["closeMinute"] as! Int? ?? 0
//        let closeHour = dictionary["closeHour"] as! Int? ?? 0
//        // ******* how to create a GMSTime object with closeHour & closeMinute as parameters
//        let closeTime = GMSTime()
//        let openMinute = dictionary["openMinute"] as! Int? ?? 0
//        let openHour = dictionary["openHour"] as! Int? ?? 0
//        // ******* how to create a GMSTime object with openHour & openMinute as parameters
//        let openTime = GMSTime()
//        // ******* how to create a GMSEvent object with openTime as parameter
//        let openEvent = GMSEvent()
//        // ******* how to create a GMSEvent object with closeTime as parameter
//        let closeEvent = GMSEvent()
//        // ******* how to create a GMSPeriod object with openEvent and closeEvent as part of array
//        let period = [GMSPeriod()]
        let weekdayText = dictionary["weekdayText"] as! String? ?? ""
        // ******* how to create a GMSOpeningHours object with period OR weekdayText as parameter
        let hours = GMSOpeningHours()
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let isOpen = GMSPlaceOpenStatus(rawValue: 0) ?? GMSPlaceOpenStatus.unknown
        let userID = dictionary["userID"] as! String? ?? ""
        //add viewport: viewport, to function call
        self.init(name: name, address: address, coordinate: coordinate, hours: hours, date: date, isOpen: isOpen, userID: userID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //Grab the user ID
        guard let userID = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.userID = userID
        //create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        //if we have saved a record well have an id, otherwise .addDocument will create one
        if self.documentID == "" { //create a new doc via .addDocument
            var ref: DocumentReference? = nil //firestore will create a new ID for us
            ref = db.collection("malls").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("😡 ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("💨 Added document: \(self.documentID)") //it worked!
                completion(true)
            }
        } else { //else save to the existing document id
            let ref = db.collection("malls").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("😡 ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("💨 Updated document: \(self.documentID)") //it worked!
                completion(true)
            }
        }
    }
}
