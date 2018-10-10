//
//  ViewController.swift
//  Rida
//
//  Created by Julius Park on 10/8/18.
//  Copyright © 2018 Julius Park. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RideGeometry: NSObject, NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(self.points, forKey: "points")
        coder.encode(self.creationTime, forKey: "creationTime")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let points = decoder.decodeObject(forKey: "points") as? Array<CLLocation>
        guard let creationTime = decoder.decodeObject(forKey: "creationTime") as? Float64 else {return nil}
        self.init(points: points!, creationTime: creationTime)
    }
    
    var points: Array<CLLocation>
    let creationTime: Float64
    init(points: Array<CLLocation> = Array<CLLocation>(), creationTime: Float64 = Date().timeIntervalSinceReferenceDate){
        self.points = points
        self.creationTime = creationTime
    }
}


class ViewController: UIViewController{
    //Properties
    @IBOutlet weak var recordButtonContent: UIButton!
    @IBOutlet weak var Map: MKMapView!
    
    //global vars
    var isRecording = false
    var curRide:Ride? = nil
    
    @IBAction func recordButton(_ sender: UIButton, forEvent event: UIEvent) {
        fetchRides()
        isRecording = !isRecording
        if(isRecording == false && curRide != nil){
            if(curRide?.rideGeometry !=  nil){
                saveRide()
            }
            curRide = nil
        }
        else if(isRecording ==  true && curRide == nil){
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            curRide = Ride.init(entity: NSEntityDescription.entity(forEntityName: "Ride", in:managedContext)!, insertInto: managedContext)
            curRide?.rideGeometry = RideGeometry()
        }
        if(isRecording ==  true){
            recordButtonContent.setTitle("End", for: .normal)
        }
        else if(isRecording == false){
            recordButtonContent.setTitle("Start", for: .normal)
        }
        print(isRecording)
    }
    
    var locationManager: CLLocationManager = CLLocationManager()
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 1
        locationManager.startUpdatingLocation()
        Map.delegate = self
        Map.showsUserLocation = true
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ride")
        
        // Create Batch Delete Request
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(batchDeleteRequest)
            
        } catch {
            // Error Handling
        }
    }
    
    func saveRide(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        if(curRide?.rideGeometry == nil){
            curRide?.rideGeometry = RideGeometry()
        }
        curRide!.setValue(curRide?.rideGeometry, forKeyPath: "rideGeometry")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        fetchRides()
    }
    
    func fetchRides(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let rideFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Ride")
        let rideResults = try! managedContext.fetch(rideFetch)
        for ride in rideResults{
            print((ride as! Ride).rideGeometry)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

}

//location manager stuff
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation: CLLocation = locations[locations.count - 1]
        animateMap(lastLocation)
        if(curRide != nil){
            if(isRecording == true){
                (curRide!.rideGeometry as! RideGeometry).points.append(lastLocation)
                drawLine(line: (curRide!.rideGeometry as! RideGeometry).points)
            }
        }
    }
}


//map stuff
extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    func drawLine(line: Array<CLLocation>){
        var coords = Array<CLLocationCoordinate2D>()
        for point in line {
            coords.append(point.coordinate as CLLocationCoordinate2D)
        }
        Map.removeOverlays(Map.overlays)
        print(MKPolyline.init(coordinates: &coords, count: coords.count))
        Map.addOverlay(MKPolyline.init(coordinates: &coords, count: coords.count))
    }
    func animateMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        Map.setRegion(region, animated: true)
    }
}

