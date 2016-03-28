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
    var encodedPoly: String
    var instructions: String = ""
    
    init(dur: Int, dist: Int, coor: CLLocationCoordinate2D, poly: String, inst: String) {
        self.duration = dur
        self.distance = dist
        self.coordinates = coor
        self.encodedPoly = poly
        self.instructions = inst
    }
}

class BuildingViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var lockMap: UIButton!
    @IBOutlet weak var selectDestination: UIButton!
    
    var locationManager = CLLocationManager()
    
    /*
        Test coordinates:
            Origin: 36.131648, -80.275542 (Collins)
            Dest:   36.133349, -80.276640 (Manchester)
    
            Near [1]
            36.131834, -80.275709
            Near [2]
            36.131931, -80.275800
            Near [3]
            36.132050, -80.275792
            Near [4]
            36.132314, -80.275765
            Near [5]
            36.132426, -80.275853
            Near [6] (Major)
            36.132574, -80.275999
            Near [8]
            36.132736, -80.276154
            Near [9]
            36.132831, -80.276253
            Near [10]
            36.133132, -80.276535
            Near [11]
            36.133216, -80.276618
            Near End
            36.133311, -80.276622
    */
    var collins = CLLocationCoordinate2D(latitude: 36.131648, longitude: -80.275542)
    var manchester = CLLocationCoordinate2D(latitude: 36.133349, longitude: -80.276640)
    var origin = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var destination = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var ServerAPIKey: String = ""
    
    var path = GMSMutablePath() //Array of CLLocationCoordinate2D
    var polyline = GMSPolyline()
    var stepsArr = [Steps]() //Each step
    
    var doneParse = false
    var initialLoc = true
    var mapLock = true
    var pathIndex = 0
    var stepIndex = 1
    
    var oldDist: CLLocationDistance = 0.0
    var pathCount: Int = 0
    
    var passedValue: String = ""
    
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
        
        /*
            Note: viewDidLoad gets run a second time when segue back from search table view
        */
        
        //For debug
        let camera = GMSCameraPosition.cameraWithLatitude(36.131648, longitude: -80.275542, zoom: 16.5)
        mapView.camera = camera
        
        view.bringSubviewToFront(self.instructionsLabel)
        view.bringSubviewToFront(self.lockMap)
        
    }
    
    func setup(dest: String) {
        print("Found destination: ", dest)
        print("Coord: ", destination.latitude, ", ", destination.longitude)
        
        //Call Google Directions API for turn-by-turn navigataion
        callDirectionsAPI()
        
        /*
        Must be some better way
        */
        while (true) {
            if (doneParse == true) {
                
                //Add every coordinate in encoded polyline to path
                for (var i = 0; i < stepsArr.count; i++) {
                    let testPath = GMSMutablePath.init(fromEncodedPath: stepsArr[i].encodedPoly)
                    for (var j = 0; j < Int(testPath!.count()); j++) {
                        path.addCoordinate((testPath?.coordinateAtIndex(UInt(j)))!)
                    }
                }
                
                break
            }
        }
        
        //Update total number of coordinates in path
        pathCount = Int(path.count())
        print(pathCount)
        print(stepsArr.count)
        
        //Adding markers to ALL coordinates for test
        for (var i = 0; i < pathCount; i++) {
            let marker = GMSMarker(position: path.coordinateAtIndex(UInt(i)))
            marker.title = String(i)
            marker.map = mapView
        }
        
        //Update polyline
        polyline.path = path
        
        //Update instructions label
        //updateInstructionsLabel(stepsArr[0].instructions)
        
        //Put marker on destination
        updateDestMarker(manchester)
    }
    
    /*
        Notes
            1. Can probably simplify HTTP request, later
     
        Issues:
            1. MARKERS NOT APPEARING AFTER SEGUE ADDED. Segues not configured correctly? Can't update HTML tag as well now.
                ^ Check this. Is this still hapenning?
    
     */
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        //Just to retrieve initial locations for setup
        if (initialLoc == true) {
            
            //Set navigation origin location to current GPS location
            origin = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude
            )
            
            print("Updated Origin") //DONT FORGET TO CHANGE API TO GET ORIGIN
            
            initialLoc = false
        } else { //Else,
            
            //Update map with current location
            updateMap(location)
            
            /*
            For each GPS update, check location of user against next waypoint on route. If distance within 6 meters (18 feet), increment pathIndex and now draw polyline from location to NEXT waypoint (if there is one), and start comparing user location to NEXT waypoint, etc.
            */
            
            //Replace polyline to start display from where you are
            path.replaceCoordinateAtIndex(UInt(0), withCoordinate: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
            polyline.path = path
            
            //Get distance from current to next waypoint in path
            let waypoint = CLLocation(latitude: path.coordinateAtIndex(UInt(1)).latitude, longitude: path.coordinateAtIndex(UInt(1)).longitude) //distanceFromLocation only takes CLLocation
            let locToWaypoint = location.distanceFromLocation(waypoint) //Returns distance in meters
            if (locToWaypoint != oldDist) { //Don't need to print everytime
                print(locToWaypoint, ", path: ", pathIndex)
                oldDist = locToWaypoint
            }
            
            //If closer than 6 meters, change polyline to next waypoint
            if (locToWaypoint < 6) {
                //If not on last step
                if (pathIndex < (pathCount - 1)) {
                    //Remove last path
                    //print("Removing: ", path.coordinateAtIndex(UInt(0)))
                    print("Removing path")
                    path.removeCoordinateAtIndex(UInt(0))
                    pathIndex++
                    
                    //If finishing current step, update instructions label
                    let nextPath = CLLocation(latitude: path.coordinateAtIndex(UInt(0)).latitude, longitude: path.coordinateAtIndex(UInt(0)).longitude)
                    let endOfCurrentStep = CLLocation(latitude: stepsArr[stepIndex-1].coordinates.latitude, longitude: stepsArr[stepIndex-1].coordinates.longitude)
                    let locToEndStep = endOfCurrentStep.distanceFromLocation(nextPath)
                    if (locToEndStep < 6) {
                        print("Updating Instructions")
                        updateInstructionsLabel(stepsArr[stepIndex].instructions)
                        if (stepIndex + 1 < stepsArr.count) {
                            stepIndex++
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    
    func callDirectionsAPI() {
        let endpoint = "https://maps.googleapis.com/maps/api/directions/json?origin=\(collins.latitude),\(collins.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=walking&key=\(ServerAPIKey)"
        
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
                                
                                //For every waypoint in the route
                                for step in steps {
                                    
                                    //Add coordinates path, instead of using encoded polyline
                                    if let coorLat = step["end_location"]!["lat"] as? Double {                                        if let coorLong = step["end_location"]!["lng"] as? Double {
                                            if let dist = step["distance"]!["value"] as? Int {
                                                if let dur = step["duration"]!["value"] as? Int {
                                                    if let instructions = step["html_instructions"] as? String {
                                                        if let encPoly = step["polyline"]!["points"] as? String {
                                                            //Storing to stepsArr
                                                            self.stepsArr.append(Steps(dur: dur, dist: dist, coor: CLLocationCoordinate2DMake(coorLat, coorLong), poly: encPoly, inst: instructions))
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                } //End step loop
                            }
                            
                            //Done adding CLLocation to path, time to update polyline
                            self.doneParse = true
                            
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
    
    func updateDestMarker(destCoord: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: destCoord)
        marker.title = "Destination"
        marker.opacity = 0.8
        marker.map = mapView
    }

    
    @IBAction func lockMapButtion(sender: AnyObject) {
        if (mapLock == true) {
            print("Unlocking map")
            mapLock = false
            lockMap.selected = false
        } else {
            print("Locking map")
            mapLock = true
            lockMap.selected = true
        }

    }
    
    func updateMap(coord: CLLocation) {
        //If locked
        if (mapLock == true) {
            //Update camera view
            let camera: GMSCameraPosition = GMSCameraPosition.cameraWithTarget(coord.coordinate, zoom: 16.5)
            mapView.camera = camera
            
            //Update mapView with padding to show whole path
            if (Int(path.count()) > 0) {
                let pathBound = GMSCameraUpdate.fitBounds(GMSCoordinateBounds.init(path: path), withPadding: 130.0)
                mapView.moveCamera(pathBound)
            }
        }
        //Else, don't update mapView
    }
    
    @IBAction func selectDestinationButton(sender: AnyObject) {
        print("Selecting Destination")
    }
    
    @IBAction func backButtonSegue(segue:UIStoryboardSegue) {
        print("Back Segue")
    }
    
    @IBAction func sendDestinationSegue(segue:UIStoryboardSegue) {
        print("Send Data Segue")
        
        if (segue.identifier != nil) {
            if segue.identifier == "segueBackWithData" {
                
                let viewController = segue.sourceViewController as! SearchViewController
                
                let indexPath = viewController.tableView.indexPathForSelectedRow!
                let currentCell = viewController.tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
                
                print(currentCell.textLabel!.text)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

