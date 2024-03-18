//
//  ViewController.swift
//  GPSLab7
//
//  Created by user236101 on 3/15/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var lblRed: UILabel!
    @IBOutlet weak var lblGreen: UILabel!
    @IBOutlet weak var lblCurrentSpeed: UILabel!
    @IBOutlet weak var lblMaxSpeed: UILabel!
    @IBOutlet weak var lblAvgSpeed: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblMaxAcceleration: UILabel!
    
    
    var locationManager = CLLocationManager()
    var lastKnownLocation: CLLocation? //To store last known location
    var showLastKnownLocation = false
    var maxSpeed: CLLocationSpeed = 0
    var totalDistance: CLLocationDistance = 0
    var startTime: Date?
    var maxAcceleration: Double = 0
    
    @IBAction func BtnStop(_ sender: Any) {
        locationManager.stopUpdatingLocation() // Stop the user location updates
        mapView.showsUserLocation = false // Hide driver location on the map
        lblGreen.backgroundColor = .gray
        lastKnownLocation = locationManager.location //Store the last known location
        showLastKnownLocation = true
        resetTripData()
    }
    
    @IBAction func btnStart(_ sender: Any) {
        locationManager.startUpdatingLocation() // Start updating the location
        mapView.showsUserLocation = true // Show user location on the map
        showLastKnownLocation = false
        lblGreen.backgroundColor = .green
        showMaxSpeed()
        startTime = Date()
        showAvgSpeed()
        showTotalDistance()
        showMaxAccelerate()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request location authorization
        mapView.showsUserLocation = true
        
        lblCurrentSpeed.text = "0.0 km/h"
        lblMaxSpeed.text = "0.0 km/h"
        lblAvgSpeed.text = "0.0 km/h"
        lblDistance.text = "0.0 km"
        lblMaxAcceleration.text = "0.0 m/s²"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
            print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)") //Printing current location
            //Zoom driver's location
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            //Pin the current location
            addAnnotation(at: location, title: "Current Location")
            
            //Display current location
            let speedKPH = location.speed * 3.6
            lblCurrentSpeed.text = String(format: "%.2f km/h", speedKPH) //Convert m/s to km/h
        
            //Calculate and update maximum speed
            if speedKPH > maxSpeed{
                maxSpeed = speedKPH
                lblMaxSpeed.text = String(format: "%.2f km/h", maxSpeed)
            }
        //Label color will change if speed exceeds 115 km/h
            if speedKPH > 115{
                lblRed.backgroundColor = .red
                 print("The driver travelled \(String(format: "%.2f", totalDistance/1000)) km before exceeding the speed limit.")
            } else {
                lblRed.backgroundColor = .clear
    }
        
            //Calculate and update average speed
        if let startTime = startTime{
            let timeElapsed = Date().timeIntervalSince(startTime)
            let avgSpeed = (totalDistance / 1000) / (timeElapsed / 3600)
            lblAvgSpeed.text = String(format: "%.2f km/h", avgSpeed)
        }
            //Calculate and update total distance
        if let lastLocation = lastKnownLocation{
            totalDistance += location.distance(from: lastLocation)
            lblDistance.text = String(format: "%.2f km", totalDistance / 1000) //Converting meters to kilometers
        }
        //Calculate max acceleration
        if let lastLocation = lastKnownLocation {
            let timeDifference = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            let speedDifference = location.speed - lastLocation.speed
            let acceleration = speedDifference / timeDifference
            let absoluteAcceleration = abs(acceleration)
            if absoluteAcceleration > maxAcceleration {
                maxAcceleration = absoluteAcceleration
                lblMaxAcceleration.text = String(format: "%.2f m/s²", maxAcceleration)
            }
        }
            lastKnownLocation = location //Update the last known location
    }
    func addAnnotation(at location: CLLocation?, title: String){
        guard let location = location else {return}
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = title
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    func showMaxSpeed(){
        lblMaxSpeed.text = String(format: "%.2f km/h", maxSpeed)
    }
    func showAvgSpeed(){
        lblAvgSpeed.text = lblAvgSpeed.text ?? "0.0 km/h"
    }
    func showTotalDistance(){
        lblDistance.text = String(format: "%.2f km", totalDistance / 1000)
    }
    func resetTripData(){
        maxSpeed = 0
        totalDistance = 0
    }
    func showMaxAccelerate(){
        lblMaxAcceleration.text = String(format: "%.2f m/s²", maxAcceleration)
    }
}
