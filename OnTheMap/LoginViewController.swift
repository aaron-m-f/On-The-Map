//
//  ViewController.swift
//  On The Map
//
//  Created by AARON FARBER on 3/27/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit

class LoginViewController: InputViewController {
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var udacitySignInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    
    @IBOutlet weak var udacitySignInIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookSignInIndicator: UIActivityIndicatorView!
    
    let udacityClient = UdacityClient.sharedInstance()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameField.delegate = self
        passwordField.delegate = self
        
        udacitySignInIndicator.stopAnimating()
        facebookSignInIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
        
        if udacityClient.loggingOut {
            udacitySignInIndicator.startAnimating()
            facebookSignInIndicator.startAnimating()
            toggleInputFieldsAndButtons()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.finishedLoggingOut), name: UdacityClient.Notification.userSignedOut, object: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func finishedLoggingOut() {
        dispatch_async(dispatch_get_main_queue()) {
            self.udacitySignInIndicator.stopAnimating()
            self.facebookSignInIndicator.stopAnimating()
        
            self.toggleInputFieldsAndButtons()
        }
    }
    
    func toggleInputFieldsAndButtons() {
        userNameField.enabled = !(userNameField.enabled)
        passwordField.enabled = !(passwordField.enabled)
        udacitySignInButton.enabled = !(udacitySignInButton.enabled)
        signUpButton.enabled = !(signUpButton.enabled)
        facebookSignInButton.enabled = !(facebookSignInButton.enabled)
    }

    // MARK: Text Field Methods
    
    override func keyboardWillShow (notification : NSNotification) {
        view.bounds.origin.y = min(max(0, getKeyboardHeight(notification) - (view.frame.size.height * 0.5 - userNameField.bounds.height * 3.0)), view.frame.size.height * 0.5 - userNameField.bounds.height * 3.0)
    }
    
    // MARK: Sign In Methods
    
    @IBAction func SignInWithUdacity(sender: AnyObject) {
        toggleInputFieldsAndButtons()
        udacitySignInIndicator.startAnimating()
        
        udacityClient.signInWithUdacityUserName(userNameField.text, andPassword: passwordField.text, withCompletionHandler:  { (result : AnyObject?, error : NSError?) in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.toggleInputFieldsAndButtons()
                self.udacitySignInIndicator.stopAnimating()
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    self.presentError(error!)
                    return
                }
                
                self.performSegueWithIdentifier("USER_SIGNED_IN", sender: self)
            }
            
        })
    }
    
    @IBAction func signInWithFacebook(sender: UIButton) {
        toggleInputFieldsAndButtons()
        facebookSignInIndicator.startAnimating()
        
        udacityClient.signInWithFacebook(fromViewController: self, withCompletionHandler: { (result : AnyObject?, error : NSError?) in
            
            dispatch_async(dispatch_get_main_queue()) {

                self.toggleInputFieldsAndButtons()
                self.facebookSignInIndicator.stopAnimating()
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    self.presentError(error!)
                    return
                }
                
                /* GUARD: Did the user cancel? */
                guard (result != nil) else {
                    return
                }
                
                self.performSegueWithIdentifier("USER_SIGNED_IN", sender: self)
            }
        })
    }

    // MARK: Sign Up Methods

    @IBAction func signUpForAccount(sender: AnyObject) {
        if let requestUrl = NSURL(string: "https://www.udacity.com/account/auth#!/signin") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }    
}

