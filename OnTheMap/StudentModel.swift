//
//  DataModel.swift
//  OnTheMap
//
//  Created by AARON FARBER on 4/4/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

class StudentModel : NSObject {
    
    // MARK : Constants
    
    struct Student {
        static let objectID = "objectID"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let uniqueKey = "uniqueKey"
    }
    
    // MARK : Variables
    
    private(set) var students = [StudentInformation]()
    var userDictionary = [String : AnyObject]()
    var userObjectID : String = ""
    
    // MARK: Data Methods
    
    func setStudents(studentDict : AnyObject?) -> Bool {
        
        students = [StudentInformation]()
        
        guard let studentResults = studentDict?["results"] as? [[String : AnyObject]] else {
            return false
        }
        
        for studentData in studentResults {
            guard let student = StudentInformation.init(studentDict: studentData) else {
                return false
            }
            students.append(student)
        }
        
        return true
    }
    
    func clearStudents() {
        students = [StudentInformation]()
    }
    
    func addUserAsStudent() {
        let userAsStudent = StudentInformation(studentDict: userDictionary)!
        
        /* Erase user if already in students */
        var index = 0
        for student in students {
            if student.uniqueKey == userAsStudent.uniqueKey {
                students.removeAtIndex(index)
                break
            }
            index += 1
        }
        
        /* Add user to beginning of students */
        students.insert(userAsStudent, atIndex: 0)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> StudentModel {
        struct Singleton {
            static var sharedInstance = StudentModel()
        }
        return Singleton.sharedInstance
    }
}