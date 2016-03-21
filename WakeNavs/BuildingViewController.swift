//
//  BuildingViewController.swift
//  WakeNavs
//
//  Created by Kevin Lin on 3/18/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


class BuildingViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    
    /*
        Test coordinates:
            Origin: 36.131648, -80.275542 (Collins)
            Dest:   36.133349, -80.276640 (Manchester)
    */
    var collins = CLLocationCoordinate2D(latitude: 36.131648, longitude: -80.275542)
    var manchester = CLLocationCoordinate2D(latitude: 36.133349, longitude: -80.276640)
    
    var ServerAPIKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPIKey()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.myLocationEnabled = true
        
        callDirectionsAPI() //Test
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 16.5)
        mapView.camera = camera
    }
    
    func callDirectionsAPI() {
        let endpoint = "https://maps.googleapis.com/maps/api/directions/json?origin=\(collins.latitude),\(collins.longitude)&destination=\(manchester.latitude),\(manchester.longitude)&mode=walking&key=\(ServerAPIKey)"
        
        //Make HTTP request
        let requestURL: NSURL = NSURL(string: endpoint)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Retrieved JSON")
                
                do { //Catch error below
                    
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    /*
                        Returned JSON contains directions (NE, west..), distance, AND time for each step!
                    
                        Use this to see sample response:
                        https://maps.googleapis.com/maps/api/directions/json?origin=36.131648,-80.275542&destination=36.133349,-80.276640&mode=walking&key="REPLACE SERVER KEY HERE"
                    */
                    
                    if let unwrappedStatus = JSON["status"] as? String {
                        //If response is successful from Google
                        if unwrappedStatus == "OK" {
                            
                        } else {
                            print("Error in response: ", unwrappedStatus)
                        }
                        
                    }
                    
                } catch {
                    print("Error with JSON: \(error)")
                }
            } else {
                print("Error retrieving JSON, status: ", statusCode)
            }
        }
    
        task.resume()
    
    
    }
    
    func getAPIKey() {
        var keyList: NSDictionary?
        
        if let path = NSBundle.mainBundle().pathForResource("keys", ofType: "plist") {
            keyList = NSDictionary(contentsOfFile: path)
        }
        if let _ = keyList {
            let GoogleAPI = keyList?["ServerKey"] as? String
            
            ServerAPIKey = GoogleAPI!
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

