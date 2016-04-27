//
//  DetailViewController.swift
//  WakeNavs
//
//  Created by Kevin Lin on 4/26/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    var  theURL : String = ""
    var canGoBack: Bool = true
    var canGoForward: Bool = true

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        detailDescriptionLabel.hidden = true
    }
    
    var detailBuilding: Building?
    {
        didSet
        {
            configureView()
        }
    }
    
    func configureView()
    {
        
        if let detailBuilding = detailBuilding
        {
            
            if let detailDescriptionLabel = detailDescriptionLabel
            {
                
                detailDescriptionLabel.text = detailBuilding.name
                title = detailBuilding.name
                theURL = detailBuilding.detailURL
                
                // Do any additional setup after loading the view, typically from a nib.
                let url = NSURL (string: theURL);
                let requestObj = NSURLRequest(URL: url!);
                webView.loadRequest(requestObj);
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
}

