//
//  StudentInformation.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

struct StudentInformation {
    let objectID : String
    let uniqueKey : String
    let firstName : String
    let lastName : String
    let mapString : String
    let mediaURL : String
    let latitude : Float
    let longitude : Float
    
    init?(studentDict : [String : AnyObject]) {
        if let firstName = studentDict[ParseClient.Student.firstName] as? String,
        let lastName = studentDict[ParseClient.Student.lastName] as? String,
        let mapString = studentDict[ParseClient.Student.mapString] as? String,
        let mediaURL = studentDict[ParseClient.Student.mediaURL] as? String,
        let latitude = studentDict[ParseClient.Student.latitude] as? Float,
        let longitude = studentDict[ParseClient.Student.longitude] as? Float {
            
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
            
            if let uniqueKey = studentDict[ParseClient.Student.uniqueKey] as? String {
                self.uniqueKey = uniqueKey
            } else {
                self.uniqueKey = ""
            }
            
            if let objectID = studentDict[ParseClient.Student.objectID] as? String {
                self.objectID = objectID
            } else {
                self.objectID = ""
            }
            
        } else {
            return nil
        }
    }
}