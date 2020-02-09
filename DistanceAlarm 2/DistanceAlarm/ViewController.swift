//
//  ViewController.swift
//  DistanceAlarm
//
//  Created by Sherbet on 27/02/2019.
//  Copyright © 2019 CzarinaSy. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController
{

    @IBOutlet weak var displayDestination_outlet: UILabel!
    var counterDestination = 0
    @IBOutlet weak var displayFinal_outlet: UILabel!
    var counterFinal = 0
    @IBOutlet weak var destinationScroller_outlet: UISlider!
    
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    
    
    @IBOutlet weak var distanceRemainingToTravel: UILabel!

    
    let numArray:[Double] = [0.0, 0.01, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.5, 3.0]
    
    let locationManager = CLLocationManager()
    var prevLat: Double = 9999999.999999
    var prevLong: Double = 9999999.999999
    var totalDist: Double = 0
    var destinationDist: Double = 0
    var temp:Double = 0
    var temp2:Double = 0
    var begun: Bool = false
    
    
    @IBAction func destinationScroller_action(_ sender: UISlider)
    {
        counterDestination = Int(sender.value)
        displayDestination_outlet.text = String(numArray[Int(counterDestination)]) + " km away"
        //print("Equivalent: " + String(numArray[Int(counterDestination)]))
    }
    
    @IBAction func start(_ sender: UIButton)
    {
        destinationScroller_outlet.isEnabled = false
        //sender.isEnabled = false
        
        displayFinal_outlet.text = String(counterDestination) + " km until alarm"
        distanceTraveledLabel.text = "Distance Traveled: 0.00 km"
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse{
            totalDist = 0
            begun = false
            destinationDist = Double(numArray[Int(counterDestination)] * 1000)
            temp = Double(destinationDist / 1000)
            
            //distanceRemainingToTravel.text = "Distance Remaining: " + String(destinationDist.formatWithDecimalPlaces(decimalPlaces: 1))
            distanceRemainingToTravel.text = "Distance Remaining: " + String(temp.formatWithDecimalPlaces(decimalPlaces: 2)) + " km"
            displayFinal_outlet.text = "Traveling"
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func stop(_ sender: UIButton)
    {
        destinationScroller_outlet.isEnabled = true
        //displayFinal_outlet.text = "0 km until alarm"
        displayFinal_outlet.text = "Stopped"
        begun = true
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse{
            locationManager.stopUpdatingLocation()
        }
        distanceTraveledLabel.text = "Distance Traveled: N/A"
        distanceRemainingToTravel.text = "Distance Remaining: N/A"

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupSliderValues()
        checkLocationServices()

    }
    
    
    func setupSliderValues(){
        destinationScroller_outlet.minimumValue = 0
        destinationScroller_outlet.maximumValue = Float(numArray.count - 1)
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
            
        }
        else{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            if let location = locationManager.location{
                prevLat = location.coordinate.latitude
                prevLong = location.coordinate.longitude
            }

            break
        case .denied:
            //Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //Show alert to notify what's happening
            break
        case .authorizedAlways:
            break
        }
    }

}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //edit
        guard let location = locations.last else {return}
        let locationAge = -location.timestamp.timeIntervalSinceNow
        if locationAge > 30.0{
            return
        }
        if location.horizontalAccuracy < 0{
            return
        }
        
        let coordinatePrev = CLLocation(latitude: self.prevLat, longitude: self.prevLong)
        let coordinateCurr = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let travelledDist: Double = coordinateCurr.distance(from: coordinatePrev)
        
        self.totalDist += travelledDist
        self.destinationDist -= travelledDist
        self.temp = self.destinationDist / 1000
        self.temp2 = self.totalDist / 1000
        if self.totalDist < 0{
            self.totalDist = 0
        }
        if self.destinationDist <= 0{
            self.locationManager.stopUpdatingLocation()
            
            //self.distanceTraveledLabel.text = "Distance traveled: " + String(self.totalDist)
            
            self.distanceTraveledLabel.text = "Distance Traveled: " + String(Double(self.numArray[Int(self.counterDestination)])) + " km"
            self.distanceRemainingToTravel.text = "Distance Remaining: 0.00 km"
            self.displayFinal_outlet.text = "Arrived"
            begun = false
            NotificationManager.shared.triggerAlarm(after: 2, identifier: "identifier", title: "Notice", message: "Destination Reached", category: "category")
            return
        }
        
        //self.distanceTraveledLabel.text = "Distance Traveled: " + String(self.totalDist.formatWithDecimalPlaces(decimalPlaces: 1))
        self.distanceTraveledLabel.text = "Distance Traveled: " + String(self.temp2.formatWithDecimalPlaces(decimalPlaces: 2)) + " km"
        self.distanceRemainingToTravel.text = "Distance Remaining: " + String(self.temp.formatWithDecimalPlaces(decimalPlaces: 2)) + " km"
        
        
        self.prevLat = location.coordinate.latitude
        self.prevLong = location.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //edit
        checkLocationAuthorization()
    }
    
}

extension Double {
    func formatWithDecimalPlaces(decimalPlaces: Int) -> Double {
        let formattedString = NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
        return Double(formattedString)!
    }
}




