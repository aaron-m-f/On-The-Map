//
//  ParseClient.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    let session = NSURLSession.sharedSession()
    
    // MARK : Variables
    
    private(set) var students = [StudentInformation]()
    var userDictionary = [String : AnyObject]()
    var userObjectID : String = ""
    
    // MARK: Get Array of Student Information
    
    func getStudentInformation() {
        getStudentInformationWithCompletionHandler() {result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.studentInformationError, object: error)
                
                self.getStudentInformation()
                
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.studentInformationUpdated, object: nil)
        }
    }

    private func getStudentInformationWithCompletionHandler(completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        /* Check for saved student info */
        if students.count > 0 {
            completionHandler(result: nil, error: nil)
            return
        }
        
        /* Otherwise download student info */
        var parameters = [String : AnyObject]()
        parameters[Api.Parameter.Key.limit] = Api.Parameter.Value.limit
        parameters[Api.Parameter.Key.order] = Api.Parameter.Value.order
        
        let request = getURLRequestFromParameters(parameters)
        request.addValue(Api.Application.Value.id, forHTTPHeaderField: Api.Application.Field.id)
        request.addValue(Api.Application.Value.key, forHTTPHeaderField: Api.Application.Field.key)

        NetworkModel.dataTaskWithRequest(request, udacity: false) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Was data acceptable? */
            guard self.setStudents(result) else {
                NetworkModel.sendError("Corrupted student data received.", verbose: false, withCompletionHandler: completionHandler)
                return
            }
            
            completionHandler(result: true, error: nil)
        }
    }
    
    // MARK: Place User Pin
    
    func placeUserInformation(withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        checkUserInformation() {result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            /* If user already exists, update. Otherwise, add new. */
            if result as! Int == 0 {
                self.POSTUserInformation(withCompletionHandler: completionHandler)
            } else {
                self.PUTUserInformation(withCompletionHandler: completionHandler)
            }
        }
    }
    
    private func checkUserInformation(withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        let whereData = [Api.Parameter.Key.uniqueKey : userDictionary[Student.uniqueKey] as! String]
        let whereBody = NetworkModel.getHTTPBodyFormat(whereData)
        
        var parameters = [String : AnyObject]()
        parameters[Api.Parameter.Key.whereKey] = whereBody
        
        let request = getURLRequestFromParameters(parameters)
        request.addValue(Api.Application.Value.id, forHTTPHeaderField: Api.Application.Field.id)
        request.addValue(Api.Application.Value.key, forHTTPHeaderField: Api.Application.Field.key)
        
        NetworkModel.dataTaskWithRequest(request, udacity: false) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("\(error)")

                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Was data acceptable? */
            guard let resultsArray = result?["results"] as? [[String:AnyObject]] else {
                NetworkModel.sendError("Corrupted student data received.", verbose: true, withCompletionHandler: completionHandler)
                return
            }
            
            self.userObjectID = resultsArray[0]["objectId"] as! String
            
            completionHandler(result: resultsArray.count, error: nil)
        }
    }
    
    private func POSTUserInformation(withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        let userBody = NetworkModel.getHTTPBodyFormat(userDictionary)
        
        let parameters = [String : AnyObject]()

        let request = getURLRequestFromParameters(parameters)
        request.HTTPMethod = NetworkModel.Api.Method.post
        request.addValue(Api.Application.Value.id, forHTTPHeaderField: Api.Application.Field.id)
        request.addValue(Api.Application.Value.key, forHTTPHeaderField: Api.Application.Field.key)
        request.addValue(NetworkModel.Api.Header.Value.json, forHTTPHeaderField: NetworkModel.Api.Header.Field.contentType)
        request.HTTPBody = userBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        NetworkModel.dataTaskWithRequest(request, udacity: false) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("\(error)")

                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Was data acceptable? */
            guard let userObjectID = result?["objectId"] as? String else {
                NetworkModel.sendError("Corrupted student data received.", verbose: true, withCompletionHandler: completionHandler)
                return
            }
            
            self.userObjectID = userObjectID
            
            completionHandler(result: result, error: nil)
        }
    }
    
    private func PUTUserInformation(withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        let userBody = NetworkModel.getHTTPBodyFormat(userDictionary)
        
        let parameters = [String : AnyObject]()
        
        let request = getURLRequestFromParameters(parameters, withPathExtension:"/" + userObjectID)
        request.HTTPMethod = NetworkModel.Api.Method.put
        request.addValue(Api.Application.Value.id, forHTTPHeaderField: Api.Application.Field.id)
        request.addValue(Api.Application.Value.key, forHTTPHeaderField: Api.Application.Field.key)
        request.addValue(NetworkModel.Api.Header.Value.json, forHTTPHeaderField: NetworkModel.Api.Header.Field.contentType)
        request.HTTPBody = userBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        NetworkModel.dataTaskWithRequest(request, udacity: false) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("\(error)")
                
                completionHandler(result: nil, error: error)
                return
            }
            
            completionHandler(result: result, error: nil)
        }
    }
    
    // MARK: Data Methods    
    
    private func setStudents(studentDict : AnyObject?) -> Bool {
        
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
            ++index
        }
        
        /* Add user to beginning of students */
        students.insert(userAsStudent, atIndex: 0)
    }
    
    // MARK : URL Method
    
    func getURLRequestFromParameters(parameters: [String:AnyObject], withPathExtension pathExtension: String? = nil) -> NSMutableURLRequest {
        
        var apiDict = [String:String]()
        apiDict[NetworkModel.Api.Identifier.scheme] = Api.scheme
        apiDict[NetworkModel.Api.Identifier.host] = Api.host
        apiDict[NetworkModel.Api.Identifier.path] = Api.path
            
        return NetworkModel.getURLRequestFromParameters(parameters, withApi: apiDict, withPathExtension: pathExtension)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
