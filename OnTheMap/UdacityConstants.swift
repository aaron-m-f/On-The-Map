//
//  UdacityConstants.swift
//  On The Map
//
//  Created by AARON FARBER on 3/29/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

extension UdacityClient {

    struct Api {
        static let scheme = "https"
        static let host = "www.udacity.com"
        static let path = "/api"
        
        struct Path {
            static let session = "/session"
            static let users = "/users/"
        }
                
        struct Login {
            static let udacity = "udacity"
            static let username = "username"
            static let password = "password"
        }
    }
    
    struct Notification {
        static let receivedName = "Received Names of Udacity User"
        static let userSignedOut = "Udacity User Signed Out"
    }
    
    struct Facebook {
        static let mobile = "facebook_mobile"
        static let token = "access_token"
    }
}