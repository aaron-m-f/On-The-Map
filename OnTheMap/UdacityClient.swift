//
//  UdacityClient.swift
//  On The Map
//
//  Created by AARON FARBER on 3/27/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class UdacityClient: NSObject {
    
    let session = NSURLSession.sharedSession()
    let parseClient = ParseClient.sharedInstance()
    
    // MARK : Variables
    
    private(set) var sessionID : String = ""
    private(set) var facebookToken : String = ""
    
    private(set) var loggingOut = false
    
    // MARK: Sign In Methods
    
    func signInWithUdacityUserName(username : String?, andPassword password : String?, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?)->Void) {
        
        /* GUARD: Are input variables valid and without potential SQL injection? */
        guard let username = getSanitizedInput(username) else {
            NetworkModel.sendError("User Name is empty or contains invalid characters.", verbose: true, withCompletionHandler: completionHandler)
            return
        }
        
        guard let password = getSanitizedInput(password) else {
            NetworkModel.sendError("Password is empty or contains invalid characters.", verbose: true, withCompletionHandler: completionHandler)
            return
        }
        
        /* Use user name and password */
        let signInData = [Api.Login.udacity : [Api.Login.username : username, Api.Login.password : password]]
        let signInBody = NetworkModel.getHTTPBodyFormat(signInData)
        
        signInWithUdacity(signInBody, withCompletionHandler: completionHandler)
    }
    
    func signInWithFacebook(fromViewController viewController : UIViewController, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?)->Void) {
        
        /* Check for Access Token */
        if let currentAccessToken = FBSDKAccessToken.currentAccessToken() {
            self.signInWithFacebookToken(String(currentAccessToken.tokenString), withCompletionHandler: completionHandler)
            return
        }
        
        /* Get new Access Token */
        let loginManager = FBSDKLoginManager.init()
        loginManager.logInWithReadPermissions([], fromViewController: viewController) { (result, error) -> Void in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                NetworkModel.sendError("\(error)", verbose: true, withCompletionHandler: completionHandler)
                return
            }
            
            /* GUARD: Did the user cancel? */
            guard !(result!.isCancelled) else {
                completionHandler(result: nil, error: nil)
                return
            }
            
            self.signInWithFacebookToken(String(result.token.tokenString), withCompletionHandler: completionHandler)
        }
    }
    
    private func signInWithFacebookToken(currentAccessToken : String, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?)->Void) {
        
        let signInData = [Facebook.mobile: [Facebook.token: currentAccessToken]]
        let signInBody = NetworkModel.getHTTPBodyFormat(signInData)
        
        self.signInWithUdacity(signInBody, withCompletionHandler: completionHandler)
    }
    
    private func signInWithUdacity(signInBody : String, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?)->Void) {
        
        let request  = getSessionURL()
        request.HTTPMethod = NetworkModel.Api.Method.post
        request.addValue(NetworkModel.Api.Header.Value.json, forHTTPHeaderField: NetworkModel.Api.Header.Field.accept)
        request.addValue(NetworkModel.Api.Header.Value.json, forHTTPHeaderField: NetworkModel.Api.Header.Field.contentType)
        request.HTTPBody = signInBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        NetworkModel.dataTaskWithRequest(request, udacity: true) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Get Session and User Data */
            if let result = result as? NSDictionary, sessionResult = result.objectForKey("session") as? NSDictionary, accountResult = result.objectForKey("account") as? NSDictionary  {
                self.parseClient.userDictionary[ParseClient.Student.uniqueKey] = accountResult.objectForKey("key") as! String
                self.sessionID = sessionResult.objectForKey("id") as! String
                
                self.getNameFromUdacity()
            } else {
                NetworkModel.sendError("Your request did not return acceptable data.", verbose: true, withCompletionHandler: completionHandler)
            }
            
            completionHandler(result: true, error: nil)
        }
    }
    
    // MARK: Get First and Last Name
    
    private func getNameFromUdacity() {
        
        let request = getUserURL()
        
        NetworkModel.dataTaskWithRequest(request, udacity: true) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.getNameFromUdacity()
                return
            }
            
            /* Get name of user */
            if let result = result as? NSDictionary, userResult = result.objectForKey("user") as? NSDictionary  {
                self.parseClient.userDictionary[ParseClient.Student.firstName] = userResult.objectForKey("first_name") as! String
                self.parseClient.userDictionary[ParseClient.Student.lastName] = userResult.objectForKey("last_name") as! String
                
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.receivedName, object: nil)
            } else {
                self.getNameFromUdacity()
            }
        }
    }
    
    // MARK: Sign Out Methods
    
    func signOutOfUdacity() {
        /* Reset Local Session Info */
        sessionID = ""
        loggingOut = true
        ParseClient.sharedInstance().clearStudents()
        
        /* Reset Facebook Info */
        if facebookToken != "" {
            signOutOfFacebook()
        }
        
        /* Reset Remote Session Info */
        let request = getSessionURL()
        request.HTTPMethod = NetworkModel.Api.Method.delete
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        NetworkModel.dataTaskWithRequest(request, udacity: true) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.signOutOfUdacity()
                return
            }
            
            /* Ensure response has session */
            if let result = result as? NSDictionary, _ = result.objectForKey("session") as? NSDictionary {
                self.loggingOut = false
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.userSignedOut, object: nil)
            } else {
                self.signOutOfUdacity()
            }
        }
    }
    
    private func signOutOfFacebook() {
        /* Reset Local Token Info */
        facebookToken = ""

        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
    }
    
    // MARK: Data Methods
    
    static func getUdacityData(data : NSData) -> NSData {
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
    
    private func getSanitizedInput(input : String?) -> String? {
        
        /* Remove unacceptable characters */
        guard let sanitizedInput = input?.componentsSeparatedByCharactersInSet(NSCharacterSet.URLQueryAllowedCharacterSet().invertedSet).joinWithSeparator("") else {
            return nil
        }
        
        /* Ensure input remained the same and is not empty */
        guard sanitizedInput == input && sanitizedInput.characters.count > 0 else {
            return nil
        }
        
        return sanitizedInput
    }
    
    // MARK: URL Method
    
    private func getSessionURL() -> NSMutableURLRequest {
        let parameters = [String : AnyObject]()
        
        return getURLRequestFromParameters(parameters, withPathExtension: Api.Path.session)
    }
    
    private func getUserURL() -> NSMutableURLRequest {
        let parameters = [String : AnyObject]()
                
        let pathExtension = Api.Path.users + (parseClient.userDictionary[ParseClient.Student.uniqueKey] as! String)
        return getURLRequestFromParameters(parameters, withPathExtension: pathExtension)
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
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
