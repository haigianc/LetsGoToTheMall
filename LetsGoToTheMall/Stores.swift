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
    
    func getData(placeID: String, completed: @escaping ()->()){
//        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?\(APIKeys.googlePlacesKey)&\(placeID)"
//        guard let url = URL(string: urlString) else{
//            print("😡 ERROR: Could not create a URL from \(urlString)")
//            return
//        }
//        //Create Session
//        let session = URLSession.shared
//        //Get data with .dataTask method
//        let task = session.dataTask(with: url) { (data, response, error) in
//            if let error = error{
//                print("😡 ERROR: \(error.localizedDescription)")
//            }
//            //deal with the data
//            do {
//                let results = try JSONDecoder().decode([MallData].self, from: data!)
//            } catch {
//                print("😡 JSON ERROR: \(error.localizedDescription)")
//            }
//            completed()
//        }
//        task.resume()
    }
}
