//
//  UIViewController+Keyboard.swift
//  On The Map
//
//  Created by AARON FARBER on 3/29/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit


class InputViewController : UIViewController, UITextFieldDelegate {
    // MARK: Text Field Methods
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InputViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InputViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide (notification : NSNotification) {
        view.bounds.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow (notification : NSNotification) {
        view.bounds.origin.y = getKeyboardHeight(notification)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Error Method
    
    func presentError(error : NSError) {
        if let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Error", message: errorString , preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(OKAction)
            
            presentViewController(alertController, animated: true) { }
        }
    }
}