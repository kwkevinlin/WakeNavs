//
//  DetailViewController.swift
//  WakeNavs
//
//  Created by Kevin Lin on 4/26/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    var detailBuilding: Building? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detailBuilding = detailBuilding {
            if let webView = webView {
            
                //Set Nav Bar title
                title = detailBuilding.name
                
                //Load webView
                let url = NSURL(string: detailBuilding.detailURL);
                let requestObj = NSURLRequest(URL: url!);
                webView.loadRequest(requestObj);
                
                //Notice UIWebView in Storyboard. Is it suppose to be whole screen? (Upper section encapsulates nav bar)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

