//
//  ResultViewController.swift
//  cyclotron
//
//  Created by Samuel Hooker on 24/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit
import Darwin

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userLat:Double!
    var userLng:Double!
    var destLat:Double!
    var destLng:Double!
    
    var angle:Double!
    
    var temperature:Double!
    var windSpeed: Double!
    var windAngle: Double!
    var precipProbability: Double!
    
    @IBOutlet weak var tableView: UITableView!
    
    let kWeatherKey = "63c415668a5740c1e3487ba030f52492"
    
    var n2k:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        angle = calculateAngle(userLat, x2: destLat, y1: userLng, y2: destLng)
        println(angle)
        
        self.getWeather(userLat, lng: userLng)
        
        //sleep(2)
        
        //println(precipProbability)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func calculateAngle(x1:Double, x2:Double, y1:Double, y2:Double) -> Double {
        let dy = y2-y1
        let dx = x2-x1
        
        return (atan(dy / dx) * 180 / 3.14159)
    }
    
    func getWeather(lat:Double, lng:Double) {
        
        let txtUrl: String = "https://api.forecast.io/forecast/\(kWeatherKey)/\(lat),\(lng)"
        println(txtUrl)
        let url = NSURL(string: txtUrl)!
        let urlSession = NSURLSession.sharedSession() // allows session for network calls
        
        //the following line calls the url and saves the error, data and responce within this function
        let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { (data, responce, error) -> Void in
            if error != nil{
                println(error.localizedDescription)
            }
            
            var err : NSError?
            
            //this line returns the data as an NSDictionary
            var jsonResults = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            //println(jsonResults)
            
            if err != nil{
                println("JSON error \(err?.localizedDescription)")
            }
            
            ////gets the data out of the dictionary
        
            
            
            dispatch_async(dispatch_get_main_queue(), {
                self.temperature = (jsonResults["currently"]!["temperature"]!) as Double
                self.windSpeed = (jsonResults["currently"]!["windSpeed"]!) as Double
                self.windAngle = (jsonResults["currently"]!["windBearing"]!) as Double
                self.precipProbability = (jsonResults["currently"]!["precipProbability"]!) as Double
                self.calculateDay()
            })
            
            
            
            
        })
        
        jsonQuery.resume() // makes the task run
    }
    
    func calculateDay(){
        
        //out of 60
        // 10 for temperature
        // 10 for rain
        // 20 for wind
        // 10 for traffic
        // 10 for disatnce
        
        var temperature = calculateTemperature()
        var wind = calculateWind()
        println("Temperature: \(temperature), wind: \(wind)")
        var distance = calculateDistance()
        self.tableView.reloadData()
        
    }
    
    
    func calculateTemperature() -> Int{
        var message:String!
        var score:Int!
        
        if self.temperature < 41 {
            score = 1
            message = "today is too cold"
        }
        else{
            score = Int((self.temperature - 41) / 3) + 1
            message = "a bit chilly but not too cold"
        }
        if score > 10{
            message = "a bit hot but not too bad"
            score = 10-(score-10)
            if score < 0{
                message = "today is too hot"
                score = 0
            }
        
        }
        
        if (temperature > 54) && (temperature < 71) {
            message = " temperature is perfect"
        }
        
        n2k.append(message)
        return score
        
    }
    
    func differentInAngle(a:Double, b:Double) -> Double{
        if a != b{
            var big = max(a, b)
            var small = min(a, b)
            
            var difference = big-small
            if difference > 180{
                difference = 360 - difference
                return difference
            }else{
                return difference
            }
            
        }else{
            return 0.0
        }
    }
    
    func calculateWind() -> Int{
        
        if windSpeed < 5.0{
            n2k.append("Very little wind")
            return 20
        }else if windSpeed < 20{
            
            var angle = differentInAngle(windSpeed, b: windAngle)
            if angle < 40.0 {
                n2k.append("Slight back wind")
                return 20
            }else if angle < 140{
                n2k.append("slight head wind")
                return 5
            }else{
                n2k.append("slightly windy")
                return 12
            }
        }else if windSpeed > 20 {
            var angle = differentInAngle(windSpeed, b: windAngle)
            if angle < 40.0 {
                n2k.append("Strong back wind")
                return 20
            }else if angle < 140{
                n2k.append("Strong head wind")
                return 0
            }else{
                n2k.append("Strong wind")
                return 8
            }
            
        }
        return 10
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell") as TableViewCell
        cell.label.text = n2k[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return n2k.count
    }
    
    func calculateDistance() -> Int{
        //returns int 0-10
        
        var distance = sqrt(((destLat - userLat) * (destLat - userLat)) + ((destLng - userLng) * (destLng - userLng))) * 111.2
        println("distance: \(distance)")
        
        var subtraction = Int(distance/2)
        if subtraction > 10 {
            subtraction = 10
        }
        
        if distance < 5.0 {
            n2k.append("easy cycling distance")
        } else if distance < 10.0{
            n2k.append("Trip isnt too long")
        }else if distance < 20.0 {
            n2k.append("Trip is pretty far, you can do it")
        }else if distance < 30.0 {
            n2k.append("Trip is far but I believe in you")
        }else if distance < 1000.0{
            n2k.append("Its a long trip, progress with caution")
        }else{
            n2k.append("Thats really far, I dont believe you")
        }
        
        
        
        return 10 - subtraction
    }
    
    
    
    

}
