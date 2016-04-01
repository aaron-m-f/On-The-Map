//
//  NetworkConstants.swift
//  On The Map
//
//  Created by AARON FARBER on 3/29/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

extension NetworkModel {
    struct Api {
        struct Identifier {
            static let scheme = "scheme"
            static let host = "host"
            static let path = "path"
        }
        
        struct Header {
            struct Field {
                static let accept = "Accept"
                static let contentType = "Content-Type"
            }
            
            struct Value {
                static let json = "application/json"
            }
        }
        
        struct Method {
            static let post = "POST"
            static let put = "PUT"
            static let delete = "DELETE"
        }
    }
}