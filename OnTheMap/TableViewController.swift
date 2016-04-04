//
//  TableViewController.swift
//  On The Map
//
//  Created by AARON FARBER on 3/28/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit
import MapKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var downloadingStudentsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var studentDownloadProgressLabel: UILabel!
    @IBOutlet weak var studenTableView: UITableView!
    
    let studentModel = StudentModel.sharedInstance()
    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.sharedInstance()
    let geoCodingClient = GeoCodingClient.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studenTableView.delegate = self
        studenTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if studentModel.students.count == 0 {
            studentDownloadProgressLabel.hidden = false
            downloadingStudentsIndicator.startAnimating()
            
            studenTableView.hidden = true
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewController.updateStudentTable), name: ParseClient.Notification.studentInformationUpdated, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewController.updateProgressLabel(_:)), name: ParseClient.Notification.studentInformationError, object: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Student Information
    
    func updateStudentTable() {
        studentDownloadProgressLabel.hidden = true
        downloadingStudentsIndicator.stopAnimating()
            
        studenTableView.hidden = false
        studenTableView.reloadData()
    }
    
    func updateProgressLabel(notification : NSNotification) {
        if let error = notification.object as? NSError, let errorText = error.userInfo[NSLocalizedDescriptionKey] as? String {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.studentDownloadProgressLabel.text = errorText + " Retrying..."
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return studentModel.students.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STUDENT_CELL", forIndexPath: indexPath) as! StudentTableViewCell
        
        let student = studentModel.students[indexPath.section]
        
        cell.studentNameLabel.text = student.firstName + " " + student.lastName
        cell.studentMediaURL = student.mediaURL
        
        let region = GeoCodingClient.getMKCoordinateRegion(student.latitude, longitude: student.longitude, span: 0.00125)
        
        cell.studentMapView.setRegion(region, animated: false)

        return cell
    }
}
