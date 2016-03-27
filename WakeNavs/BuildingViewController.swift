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

class Steps {
    var duration: Int = 0
    var distance: Int = 0
    var coordinates: CLLocationCoordinate2D
    var instructions: String = ""
    
    init(dur: Int, dist: Int, coor: CLLocationCoordinate2D, inst: String) {
        self.duration = dur
        self.distance = dist
        self.coordinates = coor
        self.instructions = inst
    }
}

class BuildingViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    /*
        Test coordinates:
            Origin: 36.131648, -80.275542 (Collins)
            Dest:   36.133349, -80.276640 (Manchester)
    
            Between Origin and [1]
                36.132319, -80.275763
            RIGHT beside [1]
                36.132566, -80.275993
            Between [1] and [2]
                36.132798, -80.276214
            Slightly offpath to the left
                36.132683, -80.276498
            RIGHT beside [2]
                36.133338, -80.276634
    */
    var collins = CLLocationCoordinate2D(latitude: 36.131648, longitude: -80.275542)
    var manchester = CLLocationCoordinate2D(latitude: 36.133349, longitude: -80.276640)
    
    var ServerAPIKey: String = ""
    
    var path = GMSMutablePath() //Array of CLLocationCoordinate2D
    var polyline = GMSPolyline()
    var markerArr = [GMSMarker]()
    var stepsArr = [Steps]() //Each step
    
    var addPolyline = 0
    var stepsIndex = 1
    var pathIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAPIKey()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.myLocationEnabled = true
        
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        
        //Call Google Directions API for turn-by-turn navigataion
        callDirectionsAPI()
        
        /* To display the polyline
            Issue because to draw polylines on mapView, it must be on the main thread.
            Drawing polylines inside callDirectionsAPI() will terminate because wrong thread.
        */
        while (true) {
            //HAS to be a better solution...
            if (addPolyline == 1) {
                print("Path: ", path.count())
                print("Updating polyline")
                polyline.path = path //Update polyline to display fetched coordinates
                addPolyline = 0
                
                //Test output stepsArr
                for eachStep in stepsArr {
                    print(eachStep.instructions)
                }
                
                break
            }
        }
        
        //Put marker on destination
        updateDestMarker(manchester)
        view.bringSubviewToFront(self.instructionsLabel)
        
    }
    
    /*
     
     Start from here
        Notes
            1. Can probably simplify HTTP request, later
     
        Fixes:
            Adjust screen when polyline changes
     
        Issues:
            1. Replaced polylines only go in straight lines. Problem if slightly off-path or road is curved. Have to check JSON to see if Google's directions are also in straight lines only
     
     */
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 16.5)
        mapView.camera = camera
        
        /*
            For each GPS update, check location of user against next waypoint on route. If distance within 6 meters (18 feet), increment stepsIndex and now draw polyline from location to NEXT waypoint (if there is one), and start comparing user location to NEXT waypoint, etc.
        */
        
        //Replace polyline to start display from where you are
        path.replaceCoordinateAtIndex(UInt(0), withCoordinate: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
        polyline.path = path
        
        //Get distance from current to next waypoint
        let waypoint = CLLocation(latitude: stepsArr[stepsIndex].coordinates.latitude, longitude: stepsArr[stepsIndex].coordinates.longitude) //distanceFromLocation only takes CLLocation
        let locToWaypoint = location.distanceFromLocation(waypoint) //Returns distance in meters
        print(locToWaypoint)
        
        //If closer than 6 meters, change polyline to next endpoint
        if (locToWaypoint < 16) { //Change this back to 6 when deploying
            //If not on last step
            if (stepsIndex < stepsArr.count - 1) {
                stepsIndex++
                //Remove last path
                path.removeCoordinateAtIndex(UInt(0))
                
                
            } else { //Already on last step
                
            }
            
            
        }
        
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
                    
                    //Parse JSON
                    if let unwrappedStatus = JSON["status"] as? String {
                        //If response is successful from Google
                        if unwrappedStatus == "OK" {
                            print("Status: ", unwrappedStatus)
                            
                            if let steps = JSON["routes"]!![0]["legs"]!![0]["steps"] as? [[String: AnyObject]] {
                                
                                //Adding ORIGIN as first step
                                //Pretty much just a placeholder since it will be replaced very shortly by current GPS location
                                self.path.addCoordinate(self.collins)
                                self.stepsArr.append(Steps(dur: 0, dist: 0, coor: self.collins, inst: "test"))
                                
                                //For every waypoint in the route
                                for step in steps {
                                    
                                    //Add coordinates path, instead of using encoded polyline
                                    if let coorLat = step["end_location"]!["lat"] as? Double {                                        if let coorLong = step["end_location"]!["lng"] as? Double {
                                            if let dist = step["distance"]!["value"] as? Int {
                                                if let dur = step["duration"]!["value"] as? Int {
                                                    if let instructions = step["html_instructions"] as? String {
                                                        
                                                        //Storing to stepsArr
                                                        self.stepsArr.append(Steps(dur: dur, dist: dist, coor: CLLocationCoordinate2DMake(coorLat, coorLong) , inst: instructions))
                                                        //Add current coordinates to polyline
                                                        self.path.addLatitude(coorLat, longitude: coorLong)
                                                        
                                                    }
                                                }
                                            }
                                        }
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

