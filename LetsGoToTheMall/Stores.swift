//
//  Stores.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase

class Stores {
    var storeArray: [Store] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(mall: Mall, completed: @escaping () -> ()){
        guard mall.documentID != "" else {
            return
        }
        db.collection("malls").document(mall.documentID).collection("stores").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("😡 ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.storeArray = [] //clean out existing storeArray since new data will load
            //there are querySnapshot!.documents.count documents in the malls snapshot
            for document in querySnapshot!.documents{
                //youll have to be sure youve created a dictionary intializer in the singular class (Mall, below) that accpets a dictionary
                let store = Store(dictionary: document.data())
                store.documentID = document.documentID
                self.storeArray.append(store)
            }
            completed()
        }
    }
}
