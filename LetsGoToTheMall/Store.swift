//
//  Store.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase
import MapKit
import GoogleMaps
import GooglePlaces

class Store: NSObject, MKAnnotation {
    var name: String
    var priceLevel: GMSPlacesPriceLevel
    var website: URL
    var coordinate: CLLocationCoordinate2D
    var hours: GMSOpeningHours
    var date: Date
    var isOpen: GMSPlaceOpenStatus
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        var timeIntervalDate = date.timeIntervalSince1970
        return ["name": name, "priceLevel": priceLevel, "website": website, "latitude": latitude, "longitude": longitutde, "date": timeIntervalDate, "isOpen": isOpen, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitutde: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var location: CLLocation{
        return CLLocation(latitude: latitude, longitude: longitutde)
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
    
    var title: String? {
        return name
    }
    
    init(name: String, priceLevel: GMSPlacesPriceLevel, website: URL, coordinate: CLLocationCoordinate2D, hours: GMSOpeningHours, date: Date, isOpen: GMSPlaceOpenStatus, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.priceLevel = priceLevel
        self.website = website
        self.coordinate = coordinate
        self.hours = hours
        self.date = date
        self.isOpen = isOpen
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience override init() {
        self.init(name: "", priceLevel: GMSPlacesPriceLevel(rawValue: 0) ?? GMSPlacesPriceLevel.unknown, website: URL(string: "") ?? URL(string: "https://www.google.com/?client=safari")!, coordinate: CLLocationCoordinate2D(), hours: GMSOpeningHours(), date: Date(), isOpen: GMSPlaceOpenStatus(rawValue: 0) ?? GMSPlaceOpenStatus.unknown, averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let priceLevel = GMSPlacesPriceLevel(rawValue: 0) ?? GMSPlacesPriceLevel.unknown
        let website = dictionary["website"] as! URL? ?? URL(string: "")!
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let weekdayText = dictionary["weekdayText"] as! String? ?? ""
        // ******* how to create a GMSOpeningHours object with period OR weekdayText as parameter
        let hours = GMSOpeningHours()
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let isOpen = GMSPlaceOpenStatus(rawValue: 0) ?? GMSPlaceOpenStatus.unknown
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(name: name, priceLevel: priceLevel, website: website, coordinate: coordinate, hours: hours, date: date, isOpen: isOpen, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(mall: Mall, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        
        //create dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        //if we have saved a record well have an id, otherwise .addDocument will create one
        if self.documentID == "" { //create a new doc via .addDocument
            var ref: DocumentReference? = nil //firestore will create a new ID for us
            ref = db.collection("malls").document(mall.documentID).collection("stores").addDocument(data: dataToSave){ (error) in
                guard error == nil else{
                    print("😡 ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("💨 Added document: \(self.documentID) to mall: \(mall.documentID)") //it worked!
                completion(true)
            }
        } else { //else save to the existing document id
            let ref = db.collection("malls").document(mall.documentID).collection("stores").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("😡 ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("💨 Updated document: \(self.documentID) in mall: \(mall.documentID)") //it worked!
                completion(true)
            }
        }
    }
    
    func updateAverageRating(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("spots").document(documentID).collection("reviews")
        // get all reviews
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else{
                print("😡 ERROR: failed to get query snapshot of reviews for reviewsRef \(reviewsRef)")
                return completed()
            }
            var ratingTotal = 0.0 //this will hold the total of all review ratings
            for document in querySnapshot!.documents{ // loop through all reviews
                let reviewDictionary = document.data()
                let rating = reviewDictionary["rating"] as! Int? ?? 0 //read in rating for each review
                ratingTotal = ratingTotal + Double(rating)
            }
            self.averageRating = ratingTotal / Double(querySnapshot!.count)
            self.numberOfReviews = querySnapshot!.count
            let dataToSave = self.dictionary //create a dictionary with the latest values
            let spotRef = db.collection("spots").document(self.documentID)
            spotRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("😡 ERROR: updating document \(self.documentID) in spot after changing averageReview & numberOfReviews info \(error.localizedDescription)")
                    completed()
                } else {
                    print("🔢 New Average: \(self.averageRating). Document updated with ref ID \(self.documentID)")
                    completed()
                }
            }
        }
    }
}
