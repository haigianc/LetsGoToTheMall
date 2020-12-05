//
//  Reviews.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(mall: Mall, store: Store, completed: @escaping () -> ()){
        guard mall.documentID != "" else {
            return
        }
        guard store.documentID != "" else {
            return
        }
        db.collection("malls").document(mall.documentID).collection("stores").document(store.documentID).collection("reviews").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("😡 ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.reviewArray = [] //clean out existing reviewArray since new data will load
            //there are querySnapshot!.documents.count documents in the stores snapshot
            for document in querySnapshot!.documents{
                //youll have to be sure youve created a dictionary intializer in the singular class (Mall, below) that accpets a dictionary
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}
