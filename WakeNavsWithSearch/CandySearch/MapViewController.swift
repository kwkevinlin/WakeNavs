import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lockMap: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
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
    var markerArr = [GMSMarker]()
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
        
        //Setup for split view controller
        setTitle()
        
        //Get Directions API key
        getAPIKey()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.myLocationEnabled = true
        
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        
        //Set initial location as user's current location
        //let camera = GMSCameraPosition.cameraWithTarget(origin, zoom: 18)
        //let camera = GMSCameraPosition.cameraWithLatitude(36.131648, longitude: -80.275542, zoom: 18)
        //mapView.camera = camera
        
        //Setup mapView
        setupMapView()
        
    }
    
    func setupMapView() {
        
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
        
        //Adding markers to ALL coordinates for test
        /*
        for (var i = 0; i < pathCount; i++) {
        markerArr.append(GMSMarker(position: path.coordinateAtIndex(UInt(i))))
        markerArr[markerArr.count - 1].title = String(i)
        markerArr[markerArr.count - 1].map = mapView
        }
        */
        
        //Update polyline
        polyline.path = path
        
        //Start updating in locationManager
        initialLoc = false
        
        //Update instructions label
        updateInstructionsLabel(stepsArr[0].instructions)
        
        //Put marker on destination
        updateDestMarker(manchester)
        
    }
    
    func callDirectionsAPI() {
        //let endpoint = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=walking&key=\(ServerAPIKey)"
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
    
    @IBAction func lockMapButton(sender: AnyObject) {
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
            Currently displaying HTML strings as just plain text
        */
        let encodedData = instruction.dataUsingEncoding(NSUTF8StringEncoding)!
        var attributedString: NSAttributedString?
        
        do {
            try attributedString = NSAttributedString(data: encodedData, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
            
        } catch let error as NSError {
            print("Error in decoding instructions: ", error.localizedDescription)
            attributedString = nil
        }
        
        instructionsLabel.text = attributedString!.string
    }
    
    func updateDestMarker(destCoord: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: destCoord)
        marker.title = "Destination"
        marker.opacity = 0.8
        marker.map = mapView
    }
    
    var detailBuilding: Building? {
        didSet {
            setTitle()
        }
    }
    
    func setTitle() {
        if let detailBuilding = detailBuilding {
            title = detailBuilding.name
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
