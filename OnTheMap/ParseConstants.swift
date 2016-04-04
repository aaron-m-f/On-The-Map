//
//  ParseConstants.swift
//  On The Map
//
//  Created by AARON FARBER on 3/29/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

extension ParseClient {
    
    struct Notification {
        static let studentInformationUpdated = "Student Information Updated"
        static let studentInformationError = "Student Information Error"
    }

    struct Api {
        static let scheme = "https"
        static let host = "api.parse.com"
        static let path = "/1/classes/StudentLocation"
        
        struct Application {
            struct Field {
                static let key = "X-Parse-REST-API-Key"
                static let id = "X-Parse-Application-Id"
            }
            
            struct Value {
                static let key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
                static let id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            }
        }
        
        struct Parameter {
            struct Key {
                static let limit = "limit"
                static let order = "order"
                static let whereKey = "where"
                static let uniqueKey = "uniqueKey"
            }
            
            struct Value {
                static let limit = "100"
                static let order = "-updatedAt"
            }
        }
    }
}