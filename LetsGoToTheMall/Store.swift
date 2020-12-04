//
//  Store.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase

class Store {
    var name: String
    var website: String
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "website": website, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    init(name: String, website: String, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.website = website
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
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
