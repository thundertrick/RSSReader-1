//
//  WebViewController.swift
//  RSSReader
//
//  Created by Leopold Aschenbrenner on 22/04/15.
//  Copyright (c) 2015 Leopold Aschenbrenner. All rights reserved.
//

import UIKit
import WebKit
import TUSafariActivity
import ARChromeActivity

class WebViewController: UIViewController {

    var actionButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var forwardButton : UIBarButtonItem!
    var progressButton : UIBarButtonItem!
    var flexibleSpace : UIBarButtonItem!
    
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
         setUpBarButtonItems()
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        self.title = urlToLoad.description
       
        
        let url = urlToLoad
        let request = NSURLRequest(URL:url)
        webView.loadRequest(request)
    }
    
    func setUpBarButtonItems() {
        actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionMethod")
        backButton = UIBarButtonItem(image: UIImage(named: "backbutton"), style: .Plain, target: self, action: "goBack")
        forwardButton = UIBarButtonItem(image: UIImage(named: "forwardbutton"), style: .Plain, target: self, action: "goForward")
        if self.webView.loading == true {
            progressButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "stopLoading")
        } else {
            progressButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reload")
        }
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        self.toolbarItems = [backButton, flexibleSpace, forwardButton, flexibleSpace, progressButton, flexibleSpace, actionButton]
    }
    
    
    func reload() {
        self.webView.reload()
    }
    func stopLoading() {
        self.webView.stopLoading()
        
    }
    
    func goBack() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    func goForward() {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
        
    }
    
    func actionMethod() {
        let textToShare = (webView.title != nil) ? webView.title! : ""
            if let link = webView.URL {
                let objectsToShare = [textToShare, link]
                let safariActivity = TUSafariActivity()
                let chromeActivity = ARChromeActivity()
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [safariActivity, chromeActivity])
                if activityVC.respondsToSelector("popoverPresentationController") {
                    // iOS 8+
                    let presentationController = activityVC.popoverPresentationController
                    presentationController?.sourceView = view
                    presentationController?.barButtonItem = actionButton
                }
                self.presentViewController(activityVC, animated: true, completion: nil)
                
                
        }

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
