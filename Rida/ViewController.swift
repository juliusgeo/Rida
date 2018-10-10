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

class Point {
    let coord: CLLocation
    let time: Float64
    init(coord: CLLocation){
        self.coord = coord
        self.time = Date().timeIntervalSinceReferenceDate
    }
}
class RideGeometry {
    var points: Array<Point>
    let creationTime: Float64
    init(){
        self.points = Array<Point>()
        self.creationTime = Date().timeIntervalSinceReferenceDate
    }
}
class ViewController: UIViewController{
    //Properties
    @IBOutlet weak var recordButtonContent: UIButton!
    @IBOutlet weak var Map: MKMapView!
    
    //global vars
    var isRecording = false
    var curRide:RideGeometry? = nil
    @IBAction func recordButton(_ sender: UIButton, forEvent event: UIEvent) {
        isRecording = !isRecording
        if(isRecording == false && curRide != nil){
            //save ride
            curRide = nil
        }
        else if(isRecording ==  true && curRide == nil){
            curRide = RideGeometry()
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
                curRide!.points.append(Point(coord: lastLocation))
                drawLine(line: (curRide?.points)!)
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
    func drawLine(line: Array<Point>){
        var coords = Array<CLLocationCoordinate2D>()
        for point in line {
            coords.append(point.coord.coordinate as CLLocationCoordinate2D)
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

