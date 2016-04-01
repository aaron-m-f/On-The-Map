//
//  MapViewController.swift
//  On The Map
//
//  Created by AARON FARBER on 3/27/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func userDidAcceptPinLocation(didAccept : Bool, mapViewController : MapViewController)
}

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var downloadingStudentsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var studentDownloadProgressLabel: UILabel!
    
    @IBOutlet weak var emptyView: UIImageView!
    
    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.sharedInstance()
    let geoCodingClient = GeoCodingClient.sharedInstance()
    
    var delegate : SubmitViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        /* User is placing geoCode onto map */
        if geoCodingClient.placingMark == true {
            mapView.mapType = MKMapType.Hybrid
            goToUserInputtedRegion()
            
        /* Student List has already been loaded */
        } else if parseClient.students.count > 0 {
            setStudentAnnotations()
        
        /* Student List still loading */
        } else {
            studentDownloadProgressLabel.hidden = false
            downloadingStudentsIndicator.startAnimating()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.setStudentAnnotations), name: ParseClient.Notification.studentInformationUpdated, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.updateProgressLabel(_:)), name: ParseClient.Notification.studentInformationError, object: nil)            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Student Information
    
    func updateProgressLabel(notification : NSNotification) {
        if let error = notification.object as? NSError, let errorText = error.userInfo[NSLocalizedDescriptionKey] as? String {

            dispatch_async(dispatch_get_main_queue()) {
                self.studentDownloadProgressLabel.text = errorText + " Retrying..."
            }
        }
    }
    
    // MARK: - Add User Method
    
    func goToUserInputtedRegion() {
        let coordinate = geoCodingClient.currentCoordinate
        
        let region = GeoCodingClient.getMKCoordinateRegion(coordinate.latitude, longitude: coordinate.longitude, span: 0.0025)
        
        mapView.setRegion(region, animated: true)
        setUserAnnotation()
        presentUserActionSheet()
    }
    
    func presentUserActionSheet() {
        
        let alertController = UIAlertController(title: "Join The Map", message: "Place your pin here?", preferredStyle: .ActionSheet) // 1
        
        let acceptAction = UIAlertAction(title: "Accept", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.delegate?.userDidAcceptPinLocation(true, mapViewController: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            self.delegate?.userDidAcceptPinLocation(false, mapViewController: self)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(cancelAction)

        // show action sheet
        
        alertController.popoverPresentationController?.sourceView = emptyView
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - MapView Annotations
    
    func setStudentAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        for student in parseClient.students {
            annotations.append(getAnnotation(student))
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func setUserAnnotation() {

        var annotations = [MKPointAnnotation]()
        
        let userAsStudent = StudentInformation(studentDict: parseClient.userDictionary)!
        annotations.append(getAnnotation(userAsStudent))

        self.mapView.addAnnotations(annotations)
    }
    
    func getAnnotation(student : StudentInformation) -> MKPointAnnotation {
        let lat = CLLocationDegrees(student.latitude)
        let long = CLLocationDegrees(student.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL
        
        return annotation
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        studentDownloadProgressLabel.hidden = true
        downloadingStudentsIndicator.stopAnimating()
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {                
                 UIApplication.sharedApplication().openURL(NSURL(string: toOpen)!)
            }
        }
    }
}
