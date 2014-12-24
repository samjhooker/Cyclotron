//
//  LocationViewController.swift
//  cyclotron
//
//  Created by Samuel Hooker on 24/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {

    var userLat:Double!
    var userLng:Double!
    var destLat:Double!
    var destLng:Double!
    var userName:AnyObject!
    var destName:AnyObject!
    
    @IBOutlet weak var enterUserLocationTextField: UITextField!
    
    @IBOutlet weak var enterDestinationLocationTextField: UITextField!
    @IBOutlet weak var UserLocationTextView: UITextView!
    

    
    @IBOutlet weak var destinationLocationTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func userLocationSearchButtonPressed(sender: AnyObject) {
        self.findLocation(enterUserLocationTextField.text, user: true)
    }
    
    @IBAction func detectLocationButtonPressed(sender: AnyObject) {
    }

    
    @IBAction func destinationLocationButtonPressed(sender: AnyObject) {
        self.findLocation(enterDestinationLocationTextField.text, user: false)
    }
    
    
    func findLocation(text:String, user:Bool) {
        
        var escapedAddress = text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let urlpath = "http://maps.googleapis.com/maps/api/geocode/json?address=" + escapedAddress!
        println(urlpath)
        
        let url = NSURL(string: urlpath)!
        
        
        let urlSession = NSURLSession.sharedSession()
        
        let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { (data, responce, error) -> Void in
            
            if error != nil{
                println("there is an error")
            }
            
            var err : NSError?
            
            var results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if err != nil{
                println("there is a second error")
            }
            
            
            
            let formattedAddress: AnyObject! = results["results"]![0]!["formatted_address"]! as String
            
            var latitude: Double?
            var longitude: Double?
            
            var results0: AnyObject = results["results"]![0]!
            if let geometry = results0["geometry"] as? NSDictionary
            {
                if let location = geometry["location"] as? NSDictionary
                {
                    latitude = location["lat"] as? Double
                    longitude = location["lng"] as? Double
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { //() -> Void in
                if user == true {
                    self.userLat = latitude
                    self.userLng = longitude
                    self.userName = formattedAddress
                    self.UserLocationTextView.text = "from: " + (self.userName as String)
                    self.UserLocationTextView.textColor = UIColor.whiteColor()
                    self.UserLocationTextView.font = UIFont(name: "Helvetica Neue", size: 14)
                }else{
                    self.destLat = latitude
                    self.destLng = longitude
                    self.destName = formattedAddress
                    self.destinationLocationTextView.text = "to: " + (self.destName as String)
                    self.destinationLocationTextView.textColor = UIColor.whiteColor()
                    self.destinationLocationTextView.font = UIFont(name: "Helvetica Neue", size: 14)
                }
                
            })
            
        })
        
        jsonQuery.resume()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //none
    }
    

}
