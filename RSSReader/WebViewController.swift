//
//  WebViewController.swift
//  RSSReader
//
//  Created by Leopold Aschenbrenner on 22/04/15.
//  Copyright (c) 2015 Leopold Aschenbrenner. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    
    var webView : WKWebView!
    var urlToLoad = NSURL()
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
     init(url:NSURL) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(nibName: nil, bundle: nil)
      
        urlToLoad = url
        
    }
    
    init() {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(nibName: nil, bundle: nil)
            
        urlToLoad = NSURL(string: "http://www.google.com")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.addSubview(webView)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        let url = urlToLoad
        let request = NSURLRequest(URL:url)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
