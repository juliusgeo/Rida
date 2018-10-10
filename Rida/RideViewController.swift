//
//  ViewController.swift
//  Rida
//
//  Created by Julius Park on 10/8/18.
//  Copyright © 2018 Julius Park. All rights reserved.
//

import UIKit
import CoreData

class RideCellView:UITableViewCell{
    @IBOutlet weak var TimeLabel: UILabel!
}
class RideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    //Properties
    @IBOutlet weak var tableView: UITableView!
    
    
    //global vars
    var rides: [Ride] = []
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRides().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rides = fetchRides()
        let cell:RideCellView = tableView.dequeueReusableCell(withIdentifier: "RideCell", for: indexPath)
            as! RideCellView
        let row = indexPath.row
        let geometry:RideGeometry? = (rides[row].rideGeometry as? RideGeometry)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        cell.TimeLabel.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: (geometry?.creationTime ?? 0)))
        return cell
    }
    
    func fetchRides() -> Array<Ride>{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return Array<Ride>()
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let rideFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Ride")
        let rideResults = try! managedContext.fetch(rideFetch)
        rides = rideResults as! Array<Ride>
        return rides
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var ride: Ride? = rides[indexPath.row]
        performSegue(withIdentifier: "showDetailSegue", sender: ride)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RideInfoViewController, let detailToSend = sender as? Ride {
            vc.curRide = detailToSend
        }
    }
    
    
}
