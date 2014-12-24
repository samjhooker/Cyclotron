//
//  ResultViewController.swift
//  cyclotron
//
//  Created by Samuel Hooker on 24/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit
import Darwin

class ResultViewController: UIViewController {
    
    let userLat:Double!
    let userLng:Double!
    let destLat:Double!
    let destLng:Double!
    
    var angle:Double!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var angle = calculateAngle(userLat, x2: destLat, y1: userLng, y2: destLng)
        
        
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

}
