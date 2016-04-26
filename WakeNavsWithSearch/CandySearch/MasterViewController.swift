
import UIKit
import CoreLocation

class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var mapViewController: MapViewController? = nil
    var buildings = [Building]()
    var filteredBuildings = [Building]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // Origin location
    var locationManager = CLLocationManager()
    var origin = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Residence", "Academic", "Athletics" ,"Other"]
        tableView.tableHeaderView = searchController.searchBar
        
        // Retreive user's location
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        //building data defined here
        buildings =
            [
                Building(myName:"Alumni Hall",myKeyWords:["Deacon One Card Office","Office of the Vice President", "University Development", "Alumni and Donor Services", "Communications and External Relations","Wake Forest Magazine", "University Advancement","Residence Life and Housing Office"],myLatitude: 36.137843,myLongtitude: -80.275388, myCatogory: "Other"),
                
                Building(myName:"Babcock Residence Hall",myKeyWords:["Babcock"],myLatitude: 36.131230, myLongtitude: -80.277043, myCatogory: "Residence"),
                
                Building(myName:"Benson University Center",myKeyWords:["Benson", "Chick-Fil-A", "Salad Bar", "Moe’s", "Boar’s Head", "Wells Fargo Bank", "Post Office", "Pugh Auditorium", "BB&T ATM", "Copy Center", "LGBTQ Center"],myLatitude: 36.132552, myLongtitude: -80.277505 ,myCatogory: "Other"),
                
                Building(myName:"Bostwick Residence Hall",myKeyWords:["Bostwick"],myLatitude: 36.132156, myLongtitude: -80.275593, myCatogory: "Residence"),
                
                Building(myName:"Carswell Hall",myKeyWords:["CARS", "Department of East Asian Languages and Cultures", "Department of Communication"],myLatitude: 36.132722, myLongtitude: -80.2759800, myCatogory: "Academic"),
                
                Building(myName:"Collins Residence Hall",myKeyWords:["Collins"],myLatitude: 36.131588, myLongtitude: -80.275481, myCatogory: "Residence"),
                
                Building(myName:"Davis Residence Hall",myKeyWords:["Davis"],myLatitude: 36.133421, myLongtitude: -80.278367, myCatogory: "Residence"),
                
                Building(myName:"Dianne Daily Golf Learning Center",myKeyWords:["Golf Learning Center"],myLatitude: 36.131146, myLongtitude: -80.270462, myCatogory: "Athletics"),
                
                Building(myName:"Dogwood Residence Hall",myKeyWords:["Dogwood"],myLatitude: 36.136710, myLongtitude: -80.280713, myCatogory: "Residence"),
                
                Building(myName:"Efird Residence Hall",myKeyWords:["Efird", "Bookstore"],myLatitude: 36.134726, myLongtitude: -80.279049, myCatogory: "Residence"),
                
                Building(myName:"Farrell Hall",myKeyWords:["School of Business"],myLatitude: 36.136739, myLongtitude: -80.278194, myCatogory: "Academic"),
                
                Building(myName:"Greene Hall",myKeyWords:["GRNE", "Foreign Languages"],myLatitude: 36.133117, myLongtitude: -80.276194, myCatogory: "Academic"),
                
                Building(myName:"Haddock Golf Center",myKeyWords:["Golf Center"],myLatitude: 36.132900, myLongtitude: -80.273125, myCatogory: "Athletics"),
                
                Building(myName:"Huffman Residence Hall",myKeyWords:["Huffman", "Zick’s"],myLatitude: 36.135144, myLongtitude: -80.278361, myCatogory: "Residence"),
                
                Building(myName:"Johnson Residence Hall",myKeyWords:["Johnson"],myLatitude: 36.131863, myLongtitude: -80.276505, myCatogory: "Residence"),
                
                Building(myName:"Kentner Stadium",myKeyWords:["Track Field"],myLatitude: 36.134297, myLongtitude: -80.275008, myCatogory: "Athletics"),
                
                Building(myName:"Kirby Hall",myKeyWords:["KRBY"],myLatitude: 36.133687, myLongtitude: -80.276440, myCatogory: "Academic"),
                
                Building(myName:"Kitchin Residence Hall",myKeyWords:["Kitchen"],myLatitude: 36.134326, myLongtitude: -80.276998, myCatogory: "Residence"),
                
                Building(myName:"Leighton Tennis Stadium",myKeyWords:["Tennis Court"],myLatitude: 36.135176, myLongtitude: -80.276586, myCatogory: "Athletics"),
                
                Building(myName:"Luter Residence Hall",myKeyWords:["Luter"],myLatitude: 36.131001, myLongtitude: -80.277397, myCatogory: "Residence"),
                
                Building(myName:"Magnolia Residence Hall",myKeyWords:["Magnolia"],myLatitude: 36.136883, myLongtitude: -80.280155, myCatogory: "Residence"),
                
                Building(myName:"Manchester Athletic Center",myKeyWords:["Athletic Center"],myLatitude: 36.133832, myLongtitude: -80.275363, myCatogory: "Athletics"),
                
                Building(myName:"Manchester Hall",myKeyWords:["MANC", "Department of Computer Science", "Department of Mathematics"],myLatitude: 36.133375, myLongtitude: -80.276618, myCatogory: "Academic"),
                
                Building(myName:"Martin Residence Hall",myKeyWords:["Martin"],myLatitude: 36.138278, myLongtitude: -80.281680, myCatogory: "Residence"),
                
                Building(myName:"Miller Center",myKeyWords:["Gym"],myLatitude: 36.134243, myLongtitude: -80.274410, myCatogory: "Athletics"),
                
                Building(myName:"North Campus Dining Hall",myKeyWords:["New Pit", "The Tip", "Starbucks", "Bistro 34"],myLatitude: 36.136974, myLongtitude: -80.279409, myCatogory: "Other"),
                
                Building(myName:"North Campus Apartments",myKeyWords:["Apartments"],myLatitude: 36.134095, myLongtitude: -80.282062, myCatogory: "Residence"),
                
                Building(myName:"Olin Physical Laboratory",myKeyWords:["OLIN", "Department of Physics"],myLatitude: 36.132073, myLongtitude: -80.278966, myCatogory: "Academic"),
                
                Building(myName:"Palmer Residence Hall",myKeyWords:["Palmer"],myLatitude: 36.135579, myLongtitude: -80.272766, myCatogory: "Residence"),
                
                Building(myName:"Piccolo Residence Hall",myKeyWords:["Piccolo"],myLatitude: 36.135826, myLongtitude: -80.272541, myCatogory: "Residence"),
                
                Building(myName:"Polo Residence Hall",myKeyWords:["Polo"],myLatitude: 36.137529, myLongtitude: -80.281055, myCatogory: "Residence"),
                
                Building(myName:"Porter B. Byrum Welcome Center",myKeyWords:["Welcome Center", "Undergraduate Admission Office"],myLatitude: 36.131364, myLongtitude: -80.282319, myCatogory: "Other"),
                
                Building(myName:"Poteat Residence Hall",myKeyWords:["Poteat"],myLatitude: 36.135089, myLongtitude: -80.277731, myCatogory: "Residence"),
                
                Building(myName:"Reynolda Hall",myKeyWords:["Reynolda Hall", "Center for Global Studies", "Office of Personal and Career Development", "Office of Academic Advising", "University Registrar", "The Pit Dining Hall", "Student Financial Services", "Learning Assistant Center", "The Magnolia Room"],myLatitude: 36.133442, myLongtitude: -80.277266, myCatogory: "Other"),
                
                Building(myName:"Reynolds Gymnasium",myKeyWords:["Gym"],myLatitude: 36.134354, myLongtitude: -80.276113, myCatogory: "Athletics"),
                
                Building(myName:"Salem Hall",myKeyWords:["SALM", "Department of Chemistry"],myLatitude: 36.131350, myLongtitude: -80.278998, myCatogory: "Academic"),
                
                Building(myName:"Scales Fine Arts Center",myKeyWords:["Department of Dance, Department of Music, Department of Arts, Charlotte and Philip Hanes Art Gallery, Brendle Recital Hall, Mainstage Theatre"],myLatitude: 36.133910, myLongtitude: -80.280626, myCatogory: "Academic"),
                
                Building(myName:"South Residence Hall",myKeyWords:["South"],myLatitude: 36.131045, myLongtitude: -80.276053, myCatogory: "Residence"),
                
                Building(myName:"Spry Soccer Stadium",myKeyWords:["Soccer"],myLatitude: 36.137859, myLongtitude: -80.279360, myCatogory: "Athletics"),
                
                Building(myName:"Starling Hall",myKeyWords:["Starling"],myLatitude: 36.131173, myLongtitude: -80.283138, myCatogory: "Other"),
                
                Building(myName:"Student Apartments",myKeyWords:["Apartments"],myLatitude: 36.137605, myLongtitude: -80.282201, myCatogory: "Residence"),
                
                Building(myName:"Taylor Residence Hall",myKeyWords:["Taylor"],myLatitude: 36.134123, myLongtitude: -80.279029, myCatogory: "Residence"),
                
                Building(myName:"Tribble Hall",myKeyWords:["Department of Women and Gender Studies", "Department of Philosophy", "Department of English"],myLatitude: 36.132164, myLongtitude: -80.277174, myCatogory: "Academic"),
                
                Building(myName:"University Police",myKeyWords:["Police"],myLatitude: 36.131777, myLongtitude: -80.273598, myCatogory: "Other"),
                
                Building(myName:"Wait Chapel",myKeyWords:["Wait Chapel"],myLatitude: 36.134987, myLongtitude: -80.278732, myCatogory: "Other"),
                
                Building(myName:"WFDD Radio Station",myKeyWords:["Radio Station"],myLatitude: 36.135237, myLongtitude: -80.274040, myCatogory: "Other"),
                
                Building(myName:"Wingate Hall",myKeyWords:["Department of Religion","School of Divinity."],myLatitude: 36.135602, myLongtitude: -80.279348, myCatogory: "Academic"),
                
                Building(myName:"Winston Hall",myKeyWords:["Department of Biology"],myLatitude: 36.130908, myLongtitude: -80.279695, myCatogory: "Academic"),
                
                Building(myName:"Worrell Professional Center",myKeyWords:["School of Law"],myLatitude: 36.137184, myLongtitude: -80.274858, myCatogory: "Academic"),
                
                Building(myName:"Z. Smith Reynolds Library",myKeyWords:["Starbucks", "The Bridge", "Mac Lab", "Auditorium Rooms"],myLatitude: 36.131771, myLongtitude: -80.278315, myCatogory: "Academic")
        ]
        
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            mapViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MapViewController
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        origin = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredBuildings.count
        }
        return buildings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let building: Building
        if searchController.active && searchController.searchBar.text != "" {
            building = filteredBuildings[indexPath.row]
        } else {
            building = buildings[indexPath.row]
        }
        cell.textLabel!.text = building.name
        cell.detailTextLabel!.text = building.keyWords[0]
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredBuildings = buildings.filter({( building : Building) -> Bool in
            let categoryMatch = (scope == "All") || (building.catogory == scope)
            return categoryMatch && building.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let building: Building
                if searchController.active && searchController.searchBar.text != "" {
                    building = filteredBuildings[indexPath.row]
                } else {
                    building = buildings[indexPath.row]
                }
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController
                
                //Set selected building
                controller.detailBuilding = building
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                //Set origin location
                controller.origin = origin
            }
        }
    }
}

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}