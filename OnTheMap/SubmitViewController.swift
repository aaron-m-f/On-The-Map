//
//  SubmitViewController.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit
import MapKit

class SubmitViewController: InputViewController, MapViewControllerDelegate {

    @IBOutlet weak var userLocationLabel: UITextField!
    @IBOutlet weak var userLinkLabel: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var geocachingActivityIndicator: UIActivityIndicatorView!
    
    let studentModel = StudentModel.sharedInstance()
    let parseClient = ParseClient.sharedInstance()
    let geoCodingClient = GeoCodingClient.sharedInstance()

    var defaultLocationLabelText = ""
    var defaultLinkLabelText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLocationLabel.delegate = self
        userLinkLabel.delegate = self
        
        defaultLocationLabelText = userLocationLabel.text!
        defaultLinkLabelText = userLinkLabel.text!
        
        geocachingActivityIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func toggleInputFieldsAndButtons() {
        userLocationLabel.enabled = !(userLocationLabel.enabled)
        userLinkLabel.enabled = !(userLinkLabel.enabled)
        submitButton.enabled = !(submitButton.enabled)
    }

    // MARK: Text Field Methods
    
    override func keyboardWillShow (notification : NSNotification) {
        view.bounds.origin.y = min(max(0, getKeyboardHeight(notification) - (view.frame.size.height * 0.5 - userLocationLabel.bounds.height * 4.0)), view.frame.size.height * 0.5 - userLocationLabel.bounds.height * 2.0)
    }
    
    // MARK: Back Button Method
    
    @IBAction func backPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Submit User Pin Method

    @IBAction func submitUser(sender: UIButton) {
        toggleInputFieldsAndButtons()
        geocachingActivityIndicator.startAnimating()

        GeoCodingClient.sharedInstance().geoCodeLocation(userLocationLabel.text, withLink: userLinkLabel.text) { placemark, error in
            dispatch_async(dispatch_get_main_queue()) {
                
                self.toggleInputFieldsAndButtons()
                self.geocachingActivityIndicator.stopAnimating()

                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    print("error: \(error)")

                    self.presentError(error!)
                    return
                }
                
                let mapViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ON_THE_MAP") as! MapViewController
                mapViewController.delegate = self
                
                self.presentViewController(mapViewController, animated: true) {}
            }
        }
    }
    
    func userDidAcceptPinLocation(didAccept : Bool, mapViewController : MapViewController) {
        
        self.geoCodingClient.placingMark = false
        mapViewController.dismissViewControllerAnimated(true, completion: nil)

        if didAccept {
            toggleInputFieldsAndButtons()
            geocachingActivityIndicator.startAnimating()
            backButton.enabled = false

            studentModel.addUserAsStudent()
            parseClient.placeUserInformation() { result, error in
                dispatch_async(dispatch_get_main_queue()) {

                    self.backButton.enabled = true

                    /* GUARD: Was there an error? */
                    guard (error == nil) else {
                        print("error: \(error)")
                        
                        self.geocachingActivityIndicator.stopAnimating()
                        self.toggleInputFieldsAndButtons()
                        self.presentError(error!)
                        
                        return
                    }
                    
                    self.dismissViewControllerAnimated(true, completion: nil)

                }
            }
        }
    }
}
