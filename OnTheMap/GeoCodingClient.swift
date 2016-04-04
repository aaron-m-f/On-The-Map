//
//  GeoCodingClient.swift
//  On The Map
//
//  Created by AARON FARBER on 3/29/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation
import MapKit

class GeoCodingClient: NSObject {

    let studentModel = StudentModel.sharedInstance()

    // MARK : Variables

    var placingMark = false
    var currentCoordinate = CLLocationCoordinate2D()
    
    // MARK: Geolocation Method
    
    func geoCodeLocation(location : String?, withLink link : String?, withCompletionHandler completionHandler : (result : AnyObject?, error : NSError?)->Void) {
        
        /* GUARD: Did user input a location and link? */
        guard let location = location where location.characters.count > 0 else {
            NetworkModel.sendError("Your Location is empty.", verbose: true, withCompletionHandler: completionHandler)
            return
        }
        
        guard let link = link where link.characters.count > 0 else {
            NetworkModel.sendError("Your Link to Share is empty.", verbose: true, withCompletionHandler: completionHandler)
            return
        }
        
        let geocoder = CLGeocoder.init()
        geocoder.geocodeAddressString(location) { placemark, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                NetworkModel.sendError("Your search did not succeed.", verbose: true, withCompletionHandler: completionHandler)
                return
            }
            
            /* GUARD: Was data acceptable? */
            guard let firstPlacemark = placemark?[0] else {
                NetworkModel.sendError("Your search did not succeed.", verbose: true, withCompletionHandler: completionHandler)
                return
            }
            
            self.placingMark = true
            
            self.currentCoordinate = (firstPlacemark.location?.coordinate)!
            self.studentModel.userDictionary[StudentModel.Student.mediaURL] = link
            self.studentModel.userDictionary[StudentModel.Student.mapString] = location
            self.studentModel.userDictionary[StudentModel.Student.latitude] = self.currentCoordinate.latitude
            self.studentModel.userDictionary[StudentModel.Student.longitude] = self.currentCoordinate.longitude
            
            completionHandler(result: true, error: nil)
        }
    }
    
    // MARK: Region Method
    
    static func getMKCoordinateRegion(latitude : AnyObject, longitude : AnyObject, span : Double) -> MKCoordinateRegion {
        let spanX = span
        let spanY = span
        
        var region = MKCoordinateRegion();
        region.center.latitude = latitude as! Double
        region.center.longitude = longitude as! Double
        region.span.latitudeDelta = spanX;
        region.span.longitudeDelta = spanY;
        
        return region
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> GeoCodingClient {
        struct Singleton {
            static var sharedInstance = GeoCodingClient()
        }
        return Singleton.sharedInstance
    }
}