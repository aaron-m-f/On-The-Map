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
        if let firstName = studentDict[StudentModel.Student.firstName] as? String,
            let lastName = studentDict[StudentModel.Student.lastName] as? String,
            let mapString = studentDict[StudentModel.Student.mapString] as? String,
            let mediaURL = studentDict[StudentModel.Student.mediaURL] as? String,
            let latitude = studentDict[StudentModel.Student.latitude] as? Float,
            let longitude = studentDict[StudentModel.Student.longitude] as? Float {
            
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
            
            if let uniqueKey = studentDict[StudentModel.Student.uniqueKey] as? String {
                self.uniqueKey = uniqueKey
            } else {
                self.uniqueKey = ""
            }
            
            if let objectID = studentDict[StudentModel.Student.objectID] as? String {
                self.objectID = objectID
            } else {
                self.objectID = ""
            }
            
        } else {
            return nil
        }
    }
}