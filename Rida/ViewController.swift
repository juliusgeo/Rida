//
//  ViewController.swift
//  Rida
//
//  Created by Julius Park on 10/8/18.
//  Copyright © 2018 Julius Park. All rights reserved.
//

import UIKit
import MapKit
class Point {
    let coord: CLLocation
    let time: Float64
    init(coord: CLLocation){
        self.coord = coord
        self.time = Date().timeIntervalSinceReferenceDate
    }
}
class Ride {
    var points: Array<Point>
    let creationTime: Float64
    init(){
        self.points = Array<Point>()
        self.creationTime = Date().timeIntervalSinceReferenceDate
    }
}
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    //Properties
    @IBOutlet weak var Map: MKMapView!
    var isRecording = false
    var curRide:Ride? = nil
    @IBAction func recordButton(_ sender: UIButton, forEvent event: UIEvent) {
        curRide = Ride()
        isRecording = true
    }
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        Map.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation: CLLocation = locations[locations.count - 1]
        animateMap(lastLocation)
        drawLine(line: (curRide?.points)!)
        
    }
    
    func animateMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        Map.setRegion(region, animated: true)
    }
    func drawLine(line: Array<Point>){
        var coords = Array<CLLocationCoordinate2D>()
        for point in line {
            coords.append(point.coord.coordinate as CLLocationCoordinate2D)
        }
        Map.addOverlay(MKPolyline.init(coordinates: &coords, count: coords.count))
    }
    

}

