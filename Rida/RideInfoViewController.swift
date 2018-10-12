//
//  RideInfoViewController.swift
//  Rida
//
//  Created by Julius Park on 10/10/18.
//  Copyright © 2018 Julius Park. All rights reserved.
//

import UIKit
import MapKit

class RideInfoViewController: UIViewController{
    
    @IBOutlet weak var RideMap: MKMapView!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var elevationText: UILabel!
    
    
    //global vars
    var curRide:Ride? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        print(curRide!)
        animateMap((curRide?.rideGeometry as! RideGeometry).points[0])
        drawLine(line: (curRide?.rideGeometry as! RideGeometry).points)
        distanceText.text = String(format:"%f", getDistance(points: (curRide?.rideGeometry as! RideGeometry).points));
    }
    func getDistance(points: Array<CLLocation>) -> Double{
        var accum:Double = 0;
        for i in 0...points.count-1
        {    accum += points[i].distance(from: points[i+1])
        }
        return accum;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension RideInfoViewController: MKMapViewDelegate{
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
        RideMap.removeOverlays(RideMap.overlays)
        print(MKPolyline.init(coordinates: &coords, count: coords.count))
        RideMap.addOverlay(MKPolyline.init(coordinates: &coords, count: coords.count))
    }
    func animateMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        RideMap.setRegion(region, animated: true)
    }
}
