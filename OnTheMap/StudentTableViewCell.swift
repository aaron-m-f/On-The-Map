//
//  StudentTableViewCell.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit
import MapKit

class StudentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var studentNameLabel: UILabel!
    
    @IBOutlet weak var studentMapView: MKMapView!

    var studentMediaURL: String?
    
    @IBAction func goToStudentLink(sender: AnyObject) {
        if let toOpen = studentMediaURL {
            UIApplication.sharedApplication().openURL(NSURL(string: toOpen)!)
        }
    }
}
