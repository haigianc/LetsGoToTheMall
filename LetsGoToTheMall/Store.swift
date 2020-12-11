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
    //var priceLevel: GMSPlacesPriceLevel
    var priceLevel: Int
    var website: String
    var coordinate: CLLocationCoordinate2D
    var hours: [String]
    var date: Date
    var isOpen: Int
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["name": name, "priceLevel": priceLevel, "website": website, "latitude": latitude, "longitude": longitutde, "hours": hours, "date": timeIntervalDate, "isOpen": isOpen, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
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
    
    var title: String? {
        return name
    }
    
    init(name: String, priceLevel: Int, website: String, coordinate: CLLocationCoordinate2D, hours: [String], date: Date, isOpen: Int, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
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
        self.init(name: "", priceLevel: 0, website: "", coordinate: CLLocationCoordinate2D(), hours: [], date: Date(), isOpen: 0, averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let priceLevel = dictionary["priceLevel"] as! Int? ?? 0
        let website = dictionary["website"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let weekdayText = dictionary["weekdayText"] as! String? ?? ""
        // ******* how to create a GMSOpeningHours object with period OR weekdayText as parameter
        let hours = dictionary["hours"] as! [String]? ?? [""]
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let isOpen = dictionary["isOpen"] as! Int? ?? 0
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
    
    func deleteData(mall: Mall, store: Store, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("malls").document(mall.documentID).collection("stores").document(store.documentID).delete { (error) in
            if let error = error {
                print("😡 ERROR: deleting review documentID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            }
            else {
                print("👍 Successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
    
    func updateAverageRating(mall: Mall, completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("malls").document(mall.documentID).collection("stores").document(documentID).collection("reviews")
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
            let spotRef = db.collection("malls").document(mall.documentID).collection("stores").document(self.documentID)
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
