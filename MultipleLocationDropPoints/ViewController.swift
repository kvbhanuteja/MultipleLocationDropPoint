//
//  ViewController.swift
//  OfflineJsonIntegrationApp
//
//  Created by Bhanuteja on 16/08/17.
//  Copyright © 2017 Bhanuteja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    var shouldDropPins = false
    var locationArray:[Any] = []
    var distanceArray:[Double] = []
    var sortedArray:[Double] = []
    let locationManager = CLLocationManager()
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            map.showsUserLocation = true
            let path = Bundle.main.path(forResource: "Maintenance", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            let jsonData = try? Data(contentsOf: url)
            let json = try? JSONSerialization.jsonObject(with: jsonData!, options: [])
            if let jsonDict = json as? [String:Any]{
                locationArray = jsonDict["result"] as! [Any]
            }
            locationManager.startUpdatingLocation()
            shouldDropPins = true
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         let location = locations.first
        if shouldDropPins{
            sortedArray.removeAll()
            distanceArray.removeAll()
            for val in locationArray{
                shouldDropPins = false
                var coordinates = val as? [String:Any]
                let lat = coordinates?["latitude"] as? String
                let long = coordinates?["longitude"] as? String
                let dropPinCoordiantes = CLLocationCoordinate2DMake(Double(lat!)!, Double(long!)!)
                let droppinLocation = CLLocation(latitude: dropPinCoordiantes.latitude, longitude: dropPinCoordiantes.longitude)
                distanceArray.append((location?.distance(from: droppinLocation))!)
                sortedArray = distanceArray.sorted()
                dropPins(coordinate: dropPinCoordiantes,currentLocation: location!)
            
            }
        }
    }
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        mapView.showsUserLocation = true
    }
    
    func dropPins(coordinate:CLLocationCoordinate2D,currentLocation:CLLocation) {
        self.map.delegate = self
        let location = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        let latDiff = abs(lat - coordinate.latitude)
        let lonDiff = abs(lon - coordinate.longitude)
        let span = MKCoordinateSpanMake(latDiff*2.0, lonDiff*2.0)
        let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        map.setRegion(region, animated: true)
        map.addAnnotation(dropPin)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view)
    }
}

