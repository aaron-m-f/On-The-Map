//
//  TabBarController.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseClient.getStudentInformation()
    }
    
    @IBAction func signOut(sender: UIBarButtonItem) {
        udacityClient.signOutOfUdacity()
        
        dismissViewControllerAnimated(true, completion: nil);
    }
}
