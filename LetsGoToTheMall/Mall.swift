//
//  Mall.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/4/20.
//

import Foundation
import Firebase

class Mall {
    var name: String
    var address: String
    var userID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "userID": userID]
    }
    
    init(name: String, address: String, userID: String, documentID: String) {
        self.name = name
        self.address = address
        self.userID = userID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", address: "", userID: "", documentID: "")
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
