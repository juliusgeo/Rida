//
//  ViewController.swift
//  Rida
//
//  Created by Julius Park on 10/8/18.
//  Copyright © 2018 Julius Park. All rights reserved.
//

import UIKit
import CoreData

class RideViewController: UIViewController{
    //Properties

    
    //global vars
 
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchRides(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let rideFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Ride")
        let rideResults = try! managedContext.fetch(rideFetch)
        print(rideResults)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

