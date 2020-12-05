//
//  Malls.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase

class Malls {
    var mallArray: [Mall] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
        db.collection("malls").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("😡 ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.mallArray = [] //clean out existing mallArray since new data will load
            //there are querySnapshot!.documents.count documents in the malls snapshot
            for document in querySnapshot!.documents{
                //youll have to be sure youve created a dictionary intializer in the singular class (Mall, below) that accpets a dictionary
                let mall = Mall(dictionary: document.data())
                mall.documentID = document.documentID
                self.mallArray.append(mall)
            }
            completed()
        }
    }
}
