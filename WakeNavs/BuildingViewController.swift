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


class BuildingViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    /*
        Test coordinates:
            Origin: 36.131648, -80.275542 (Collins)
            Dest:   36.133349, -80.276640 (Manchester)
    */
    var collins = CLLocationCoordinate2D(latitude: 36.131648, longitude: -80.275542)
    var manchester = CLLocationCoordinate2D(latitude: 36.133349, longitude: -80.276640)
    
    var ServerAPIKey: String = ""
    
    var path = GMSMutablePath() //Array of CLLocationCoordinate2D
    var polyline = GMSPolyline()
    var markerArr = [GMSMarker]()
    
    var addPolyline = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPIKey()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.myLocationEnabled = true
        
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 4.0
        polyline.map = mapView
        
        callDirectionsAPI() //Test
        while (true) {
            //HAS to be a better solution...
            if (addPolyline == 1) {
                print("Path: ", path.count())
                print("Updating polyline")
                polyline.path = path //Update polyline to display fetched coordinates
                addPolyline = 0
                break
            }
            /*
                Because: All calls to the Google Maps SDK for iOS must be made from the UI thread
                    So this NEEDS to be running on main thread
            */
        }
        updateDestMarker(manchester)
        
        view.bringSubviewToFront(self.instructionsLabel)
    
    }
    
    /*
     
     Start from here
        For each step:
            1. Store coordinates to array to draw polylines later
            2. Probably store distance/duration as well to display to user for directions
            3. Probably also store html_instructions to show user directions, ie "Head northwest towards Gulley Dr"
     
        Notes:
            1. Can probably simplify HTTP request, later
            2. No idea what "\u003" and the weird symbols in response mean.
            3. When RESETTING/GETTING NEW DESTINATION, erase marker and path
     
        Done:
            Adding polyline
                But: need to add function to adjust screen
     
        Issues:
            1. Polyline won't erase as user moves (polyline is in segments). Solutions? Render polyline differently?
     
        Priority:
            1. Time steps. If GPS location near endpoint, increment to next step
                A. Depedency: Instructions, polyline
     
     */
    
    
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
                            print("Status: ", unwrappedStatus)
                            
                            if let steps = JSON["routes"]!![0]["legs"]!![0]["steps"] as? [[String: AnyObject]] {
                                
                                //Add first polyline, aka origin
                                self.path.addCoordinate(self.collins)
                                
                                //For every waypoint in the route
                                for step in steps {
                                    
                                    //Add coordinates path, instead of using encoded polyline
                                    if let coorLat = step["end_location"]!["lat"] as? Double {                                        if let coorLong = step["end_location"]!["lng"] as? Double {
                                            //Add coordinates to polyline
                                            self.path.addLatitude(coorLat, longitude: coorLong)
                                        
                                        }
                                    }
                                    
                                    if let instructions = step["html_instructions"] as? String {
                                        print (instructions)
                                        self.updateInstructionsLabel(instructions)
                                        
                                    }
                                    
                                } //End step loop
                            }
                            
                            //Done adding CLLocation to path, time to update polyline
                            self.addPolyline = 1
                            
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
    
    func updateInstructionsLabel(instruction: String) {
        /*
            This should be parsed to HTML to display
        */
        instructionsLabel.text = instruction
    }
    
    func updateDestMarker(origin: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: origin)
        marker.title = "Destination"
        marker.opacity = 0.8
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

