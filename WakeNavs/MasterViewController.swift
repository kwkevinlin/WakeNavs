//
//  MasterViewController.swift
//  WakeNavs
//
//  Created by Kevin Lin on 4/26/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import UIKit
import CoreLocation

class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var detailViewController: DetailViewController? = nil
    var buildings = [Building]()
    var filteredBuildings = [Building]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // Origin location
    var locationManager = CLLocationManager()
    var origin = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate buildings array
        defineBuildings()
        
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
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
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
        
        let reuseIdentifier = "programmaticCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! MGSwipeTableCell!
        if cell == nil {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        }
        
        let building: Building
        if searchController.active && searchController.searchBar.text != "" {
            building = filteredBuildings[indexPath.row]
        } else {
            building = buildings[indexPath.row]
        }
        
        cell.textLabel!.text = building.name
        cell.detailTextLabel!.text = building.searchWord
        
        // Create "Navigate" button on swipe right
        cell.rightButtons =  [MGSwipeButton(title: "Navigate", backgroundColor: UIColor.brownColor(), callback: {
        (sender: MGSwipeTableCell!) -> Bool in
        self.performSegueWithIdentifier("showMap", sender: self)
            return true
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        // Create "Show Details" button on swipe left
        cell.leftButtons = [ MGSwipeButton(title: "Show Details", backgroundColor: UIColor.brownColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.performSegueWithIdentifier("showDetail", sender: self)
            return true
        })]
        cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        return cell
    }

    
    
    func filterContentForSearchText(searchText: String, scope: String = "All" ) {
        filteredBuildings = buildings.filter({
                (building : Building) -> Bool in
                let categoryMatch = (scope == "All") || (building.catogory == scope)
                var found = false;
                
                if categoryMatch && building.name.lowercaseString.containsString(searchText.lowercaseString) {
                    found = true;
                }
            
                for x in building.keyWords {
                    if categoryMatch && x.lowercaseString.containsString(searchText.lowercaseString) {
                        found = true;
                        building.searchWord = x;
                    }
                }
                return found;
            }
        )
        tableView.reloadData()
    }
    
    // Pass along selected destination and user's coordinates before segue to detail/map view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let building: Building
                if searchController.active && searchController.searchBar.text != "" {
                    building = filteredBuildings[indexPath.row]
                } else {
                    building = buildings[indexPath.row]
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                //Set selected building
                controller.detailBuilding = building
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
            }
        } else if segue.identifier == "showMap" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let building: Building
                if searchController.active && searchController.searchBar.text != "" {
                    building = filteredBuildings[indexPath.row]
                } else {
                    building = buildings[indexPath.row]
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController
                
                // Send building to MapViewController
                controller.detailBuilding = building
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                // Set origin location
                controller.origin = origin
            }
        }
    }
    
    // Define buildings array for table view
    func defineBuildings() {
        buildings =
            [
                Building(myName:"Alumni Hall",myKeyWords:["Alumni Hall","Deacon One Card Office","Office of the Vice President", "University Development", "Alumni and Donor Services", "Communications and External Relations","Wake Forest Magazine", "University Advancement","Residence Life and Housing Office"],myLatitude: 36.137843,myLongtitude: -80.275388, myCatogory: "Other", myURL: "http://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/alumni-hall/"),
                
                Building(myName:"Babcock Residence Hall",myKeyWords:["Babcock"],myLatitude: 36.131230, myLongtitude: -80.277043, myCatogory: "Residence",myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/babcock-residence-hall/"),
                
                Building(myName:"Benson University Center",myKeyWords:["Benson", "Food court","Chick-Fil-A", "Salad Bar", "Moe’s", "Boar’s Head", "Wells Fargo Bank", "Post Office", "Pugh Auditorium", "BB&T ATM", "Copy Center", "LGBTQ Center"],myLatitude: 36.132552, myLongtitude: -80.277505 ,myCatogory: "Other", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/benson-university-center/"),
                
                Building(myName:"Bostwick Residence Hall",myKeyWords:["Bostwick"],myLatitude: 36.132156, myLongtitude: -80.275593, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/bostwick-residence-hall/"),
                
                Building(myName:"Carswell Hall",myKeyWords:["CARS", "Department of East Asian Languages and Cultures", "Department of Communication"],myLatitude: 36.132722, myLongtitude: -80.2759800, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/carswell-hall/"),
                
                Building(myName:"Collins Residence Hall",myKeyWords:["Collins"],myLatitude: 36.131588, myLongtitude: -80.275481, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/collins-residence-hall/"),
                
                Building(myName:"Davis Residence Hall",myKeyWords:["Davis"],myLatitude: 36.133421, myLongtitude: -80.278367, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/davis-residence-hall/"),
                
                Building(myName:"Dianne Daily Golf Learning Center",myKeyWords:["Golf Learning Center"],myLatitude: 36.131146, myLongtitude: -80.270462, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/dianne-daily-golf-learning-center/"),
                
                Building(myName:"Dogwood Residence Hall",myKeyWords:["Dogwood"],myLatitude: 36.136710, myLongtitude: -80.280713, myCatogory: "Residence",myURL: "http://rlh.wfu.edu/residences/dogwood-residence-hall/"),
                
                Building(myName:"Efird Residence Hall",myKeyWords:["Efird", "Bookstore"],myLatitude: 36.134726, myLongtitude: -80.279049, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/efird-residence-hall/"),
                
                Building(myName:"Farrell Hall",myKeyWords:["School of Business"],myLatitude: 36.136739, myLongtitude: -80.278194, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/farrell-hall/"),
                
                Building(myName:"Greene Hall",myKeyWords:["GRNE", "Foreign Languages"],myLatitude: 36.133117, myLongtitude: -80.276194, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/greene-hall/"),
                
                Building(myName:"Haddock Golf Center",myKeyWords:["Golf Center"],myLatitude: 36.132900, myLongtitude: -80.273125, myCatogory: "Athletics", myURL: "http://www.wakeforestsports.com/facilities/golf-complex.html"),
                
                Building(myName:"Huffman Residence Hall",myKeyWords:["Huffman", "Zick’s"],myLatitude: 36.135144, myLongtitude: -80.278361, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/huffman-residence-hall/"),
                
                Building(myName:"Johnson Residence Hall",myKeyWords:["Johnson"],myLatitude: 36.131863, myLongtitude: -80.276505, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/johnson-residence-hall/"),
                
                Building(myName:"Kentner Stadium",myKeyWords:["Track Field"],myLatitude: 36.134297, myLongtitude: -80.275008, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/kentner-stadium/"),
                
                Building(myName:"Kirby Hall",myKeyWords:["KRBY"],myLatitude: 36.133687, myLongtitude: -80.276440, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/calloway-center/"),
                
                Building(myName:"Kitchin Residence Hall",myKeyWords:["Kitchin"],myLatitude: 36.134326, myLongtitude: -80.276998, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/kitchin-residence-hall/"),
                
                Building(myName:"Leighton Tennis Stadium",myKeyWords:["Tennis Court"],myLatitude: 36.135176, myLongtitude: -80.276586, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/leighton-tennis-stadium/"),
                
                Building(myName:"Luter Residence Hall",myKeyWords:["Luter"],myLatitude: 36.131001, myLongtitude: -80.277397, myCatogory: "Residence",myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/luter-residence-hall/"),
                
                Building(myName:"Magnolia Residence Hall",myKeyWords:["Magnolia"],myLatitude: 36.136883, myLongtitude: -80.280155, myCatogory: "Residence",myURL: "http://rlh.wfu.edu/residences/magnolia-residence-hall/"),
                
                Building(myName:"Manchester Athletic Center",myKeyWords:["Athletic Center"],myLatitude: 36.133832, myLongtitude: -80.275363, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/manchester-athletic-center/"),
                
                Building(myName:"Manchester Hall",myKeyWords:["MANC", "Department of Computer Science", "Department of Mathematics"],myLatitude: 36.133375, myLongtitude: -80.276618, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/calloway-center/"),
                
                Building(myName:"Martin Residence Hall",myKeyWords:["Martin"],myLatitude: 36.138278, myLongtitude: -80.281680, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/martin-residence-hall/"),
                
                Building(myName:"Miller Center",myKeyWords:["Gym"],myLatitude: 36.134243, myLongtitude: -80.274410, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/miller-center/"),
                
                Building(myName:"North Campus Dining Hall",myKeyWords:["New Pit", "The Tip", "Starbucks", "Bistro 34"],myLatitude: 36.136974, myLongtitude: -80.279409, myCatogory: "Other", myURL: "http://news.wfu.edu/2014/01/15/dining-by-design/"),
                
                Building(myName:"North Campus Apartments",myKeyWords:["Apartments"],myLatitude: 36.134095, myLongtitude: -80.282062, myCatogory: "Residence", myURL: "http://rlh.wfu.edu/residences/north-campus-apartments/"),
                
                Building(myName:"Olin Physical Laboratory",myKeyWords:["OLIN", "Department of Physics"],myLatitude: 36.132073, myLongtitude: -80.278966, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/olin-physical-laboratory/"),
                
                Building(myName:"Palmer Residence Hall",myKeyWords:["Palmer"],myLatitude: 36.135579, myLongtitude: -80.272766, myCatogory: "Residence",myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/palmer-residence-hall/"),
                
                Building(myName:"Piccolo Residence Hall",myKeyWords:["Piccolo"],myLatitude: 36.135826, myLongtitude: -80.272541, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/piccolo-residence-hall/"),
                
                Building(myName:"Polo Residence Hall",myKeyWords:["Polo"],myLatitude: 36.137529, myLongtitude: -80.281055, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/polo-residence-hall/"),
                
                Building(myName:"Porter B. Byrum Welcome Center",myKeyWords:["Welcome Center", "Undergraduate Admission Office"],myLatitude: 36.131364, myLongtitude: -80.282319, myCatogory: "Other", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/porter-b-byrum-welcome-center/"),
                
                Building(myName:"Poteat Residence Hall",myKeyWords:["Poteat"],myLatitude: 36.135089, myLongtitude: -80.277731, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/poteat-residence-hall/"),
                
                Building(myName:"Reynolda Hall",myKeyWords:["Reynolda Hall", "Center for Global Studies", "Office of Personal and Career Development", "Office of Academic Advising", "University Registrar", "The Pit Dining Hall", "Student Financial Services", "Learning Assistant Center", "The Magnolia Room"],myLatitude: 36.133442, myLongtitude: -80.277266, myCatogory: "Other", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/reynolda-hall/"),
                
                Building(myName:"Reynolds Gymnasium",myKeyWords:["Gym"],myLatitude: 36.134354, myLongtitude: -80.276113, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/reynolds-gymnasium/"),
                
                Building(myName:"Salem Hall",myKeyWords:["SALM", "Department of Chemistry"],myLatitude: 36.131350, myLongtitude: -80.278998, myCatogory: "Academic",myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/salem-hall/"),
                
                Building(myName:"Scales Fine Arts Center",myKeyWords:["Department of Dance, Department of Music, Department of Arts, Charlotte and Philip Hanes Art Gallery, Brendle Recital Hall, Mainstage Theatre"],myLatitude: 36.133910, myLongtitude: -80.280626, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/scales-fine-arts-center/"),
                
                Building(myName:"South Residence Hall",myKeyWords:["South"],myLatitude: 36.131045, myLongtitude: -80.276053, myCatogory: "Residence", myURL: "http://rlh.wfu.edu/residences/south-residence-hall/"),
                
                Building(myName:"Spry Soccer Stadium",myKeyWords:["Soccer"],myLatitude: 36.137859, myLongtitude: -80.279360, myCatogory: "Athletics", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/spry-soccer-stadium/"),
                
                Building(myName:"Starling Hall",myKeyWords:["Starling"],myLatitude: 36.131173, myLongtitude: -80.283138, myCatogory: "Other", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/starling-hall/"),
                
                Building(myName:"Student Apartments",myKeyWords:["Apartments"],myLatitude: 36.137605, myLongtitude: -80.282201, myCatogory: "Residence",myURL: "http://rlh.wfu.edu/residences/student-apartments/"),
                
                Building(myName:"Taylor Residence Hall",myKeyWords:["Taylor"],myLatitude: 36.134123, myLongtitude: -80.279029, myCatogory: "Residence", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/taylor-residence-hall/"),
                
                Building(myName:"Tribble Hall",myKeyWords:["Department of Women and Gender Studies", "Department of Philosophy", "Department of English"],myLatitude: 36.132164, myLongtitude: -80.277174, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/tribble-hall/"),
                
                Building(myName:"University Police",myKeyWords:["Police"],myLatitude: 36.131777, myLongtitude: -80.273598, myCatogory: "Other", myURL: "http://police.wfu.edu"),
                
                Building(myName:"Wait Chapel",myKeyWords:["Wait Chapel"],myLatitude: 36.134987, myLongtitude: -80.278732, myCatogory: "Other", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/wait-chapel/"),
                
                Building(myName:"WFDD Radio Station",myKeyWords:["Radio Station"],myLatitude: 36.135237, myLongtitude: -80.274040, myCatogory: "Other", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/wfdd-radio-station/"),
                
                Building(myName:"Wingate Hall",myKeyWords:["Department of Religion","School of Divinity."],myLatitude: 36.135602, myLongtitude: -80.279348, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/wait-chapel/"),
                
                Building(myName:"Winston Hall",myKeyWords:["Department of Biology"],myLatitude: 36.130908, myLongtitude: -80.279695, myCatogory: "Academic",myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/winston-hall/"),
                
                Building(myName:"Worrell Professional Center",myKeyWords:["School of Law"],myLatitude: 36.137184, myLongtitude: -80.274858, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/worrell-professional-center/"),
                
                Building(myName:"Z. Smith Reynolds Library",myKeyWords:["Starbucks", "The Bridge", "Mac Lab", "Auditorium Rooms"],myLatitude: 36.131771, myLongtitude: -80.278315, myCatogory: "Academic", myURL: "https://zsr.wfu.edu/special/exhibit/wfu-buildings-and-roads/z-smith-reynolds-library/"),
                
                Building(myName:"Visitor Parking @ Welcome Center",myKeyWords:["Admissions Office","Lot S1 S2"],myLatitude: 36.131070, myLongtitude:  -80.283558, myCatogory: "Other", myURL: "http://www.wfu.edu/visitors"),
                
                Building(myName:"Visitor Parking @ Upper Quad",myKeyWords:["Wait Chapel Parking","Lot N"],myLatitude: 36.134807,  myLongtitude:  -80.277450, myCatogory: "Other", myURL: "http://www.wfu.edu/visitors"),
                
                Building(myName:"Visitor Parking @ Benson",myKeyWords:["Benson Parking","Lot C","Post Office"],myLatitude: 36.133167,   myLongtitude:  -80.278256, myCatogory: "Other", myURL: "http://www.wfu.edu/visitors")
        ]
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