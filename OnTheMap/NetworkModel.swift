//
//  NetworkModel.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

class NetworkModel: NSObject {
    
    // MARK: URL Method
    
    static func getURLRequestFromParameters(parameters: [String:AnyObject], withApi apiDict :[String : String], withPathExtension pathExtension: String? = nil) -> NSMutableURLRequest {
        
        let components = NSURLComponents()
        components.scheme = apiDict[Api.Identifier.scheme]!
        components.host = apiDict[Api.Identifier.host]!
        components.path = apiDict[Api.Identifier.path]! + (pathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return NSMutableURLRequest(URL: components.URL!)
    }
    
    // MARK: Data Methods
    
    static func dataTaskWithRequest(request : NSURLRequest, udacity: Bool, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?)->Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            guard let data = NetworkModel.checkForErrors(data, response: response, error: error, withCompletionHandler: completionHandler) else {
                return
            }
            
            /* Remove Udacity prefix information */
            if udacity {
                NetworkModel.convertDataToJSON(UdacityClient.getUdacityData(data), withCompletionHandler: completionHandler)
            } else {
                NetworkModel.convertDataToJSON(data, withCompletionHandler: completionHandler)
            }
        }
        
        task.resume()
    }
    
    static func getHTTPBodyFormat(input : AnyObject) -> String {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(input, options: NSJSONWritingOptions(rawValue:0))
            let dataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
            
            return String(dataString)
        } catch let error as NSError {
            print(error)
            
            return ""
        }
    }
    
    static func convertDataToJSON(data : NSData, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        var parsedData : AnyObject!
        
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            NetworkModel.sendError("\(error)", verbose: true, withCompletionHandler: completionHandler)
            return
        }
        completionHandler(result: parsedData, error: nil)
    }
    
    // MARK: Error Methods
    
    static func checkForErrors(data : NSData?, response : NSURLResponse?, error : NSError?, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) -> NSData? {
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            NetworkModel.sendError("\(error!.userInfo[NSLocalizedDescriptionKey]!)", verbose: true, withCompletionHandler: completionHandler)
            return nil
        }
        
        /* GUARD: Were Login Credentials Correct? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode != 403 else {
            NetworkModel.sendError("Account not found or invalid credentials.", verbose: true, withCompletionHandler: completionHandler)
            return nil
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard statusCode >= 200 && statusCode <= 299 else {
            NetworkModel.sendError("Your request did not return acceptable data.", verbose: true, withCompletionHandler: completionHandler)
            return nil
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            NetworkModel.sendError("No data was returned by the request.", verbose: true, withCompletionHandler: completionHandler)
            return nil
        }
        
        return data
    }
    
    static func sendError (error : String, verbose : Bool, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?) -> Void) {
        
        completionHandler(result: nil, error: NSError(domain: "", code: 1, userInfo: getErrorUserInfo(error, verbose: verbose)))
    }
    
    private static func getErrorUserInfo  (error : String, verbose : Bool) -> [String : String] {
        if verbose { return getErrorUserInfoVerbose(error) }
        else { return [NSLocalizedDescriptionKey : error] }
    }
    
    private static func getErrorUserInfoVerbose (error : String) -> [String : String] {
        let errorPrefix = "Sorry, there was an error with your request: "
        let errorSuffix = "\nPlease try again."
        
        return [NSLocalizedDescriptionKey : (errorPrefix + error + errorSuffix)]
        
    }
}
