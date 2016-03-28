//
//  SearchViewController.swift
//  WakeNavs
//
//  Created by 1834 Software on 3/27/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    @IBOutlet var tblSearchResults: UITableView!
    
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        
        dataArray = ["Collins", "Manchester"]
        tblSearchResults.reloadData()
    
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath)
        
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredArray[indexPath.row]
        } else {
            cell.textLabel?.text = dataArray[indexPath.row]
        }
        
        return cell
    }
    
    //Start
    var valueToPass:String!
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //print("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        
        valueToPass = currentCell.textLabel!.text
        performSegueWithIdentifier("segueBackWithData", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "segueBackWithData") {
            
            //Initialize new view controller and cast it as BuildingViewController
            let viewController = segue.destinationViewController as! BuildingViewController
            //Setup destination variable in BuildingViewController
            viewController.destination.latitude = 36.133349 //This is HARDCODED for now
            viewController.destination.longitude = -80.276640
            //Call setup function passing in valueToPass (aka selected destination)
            viewController.setup(valueToPass)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
