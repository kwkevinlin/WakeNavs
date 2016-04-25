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
        setTitle()
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
