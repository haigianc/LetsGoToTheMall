//
//  CustomAnnotation.swift
//  LetsGoToTheMall
//
//  Created by Claudine Haigian on 12/6/20.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class CustomAnnotation: MKPointAnnotation {
    var name: String
    var website: String
    var coordinates: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var latitude: CLLocationDegrees {
        return coordinates.latitude
    }
    
    var longitude: CLLocationDegrees {
        return coordinates.longitude
    }
    
    init(name: String, website: String, coordinates: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String){
        self.name = name
        self.website = website
        self.coordinates = coordinates
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience override init(){
        self.init(name: "", website: "", coordinates: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
}
    
