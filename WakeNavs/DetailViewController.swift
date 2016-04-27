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
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        detailDescriptionLabel.hidden = true
    }
    
    var detailBuilding: Building? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detailBuilding = detailBuilding {
            if let detailDescriptionLabel = detailDescriptionLabel {
                
                detailDescriptionLabel.text = detailBuilding.name
                title = detailBuilding.name
                
                //Load webView
                let url = NSURL(string: detailBuilding.detailURL);
                let requestObj = NSURLRequest(URL: url!);
                webView.loadRequest(requestObj);
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

