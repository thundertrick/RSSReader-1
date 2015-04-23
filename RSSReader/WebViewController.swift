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

class WebViewController: UIViewController, WKNavigationDelegate {

    
    // MARK: - Variables
    var actionButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var forwardButton : UIBarButtonItem!
    var stateButton : UIBarButtonItem!
    var flexibleSpace : UIBarButtonItem!
    var progressView : UIProgressView!
    
    var webView : WKWebView!
    var urlToLoad = NSURL()
    
    // MARK: Setup view
    
    required init(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }
    
     init(url:NSURL) {

        super.init(nibName: nil, bundle: nil)
      
        urlToLoad = url
        
    }
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        self.view = webView
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
            
        urlToLoad = NSURL(string: "http://www.google.com")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)

        let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        self.title = urlToLoad.description
        webView.navigationDelegate = self
        webView.opaque = true
        webView.backgroundColor = UIColor.lightGrayColor()
        instantiateProgressView()
        let url = urlToLoad
        let request = NSURLRequest(URL:url)
        webView.loadRequest(request)
         setUpBarButtonItems()
        
    }
    
    
    
    func setUpBarButtonItems() {
        actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self
            , action: "actionMethod")
        backButton = UIBarButtonItem(image: UIImage(named: "backbutton"), style: .Plain, target: self.webView, action: "goBack")
        forwardButton = UIBarButtonItem(image: UIImage(named: "forwardbutton"), style: .Plain, target: self.webView, action: "goForward")
        if self.webView.loading == true {
            stateButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self.webView, action: "stopLoading")
        } else {
            stateButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self.webView, action: "reload")
        }
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
       
        backButton.enabled = self.webView.canGoBack
        forwardButton.enabled = self.webView.canGoForward
        self.toolbarItems = [backButton, flexibleSpace, forwardButton, flexibleSpace, stateButton, flexibleSpace, actionButton]
    }
    
    
    // MARK: - ProgressView
    
    func instantiateProgressView() {
        let lineHeight: CGFloat = 2.0
        let frame : CGRect = CGRectMake(0, self.navigationController!.navigationBar.bounds.height - lineHeight, self.navigationController!.navigationBar.bounds.width, lineHeight)
        
        
        progressView = UIProgressView(frame: frame)
        self.navigationController!.navigationBar.addSubview(progressView)
    }
    
    
  /*  func clearProgressViewAnimated(animated: Bool) {
        if progressView == nil {
            return
        }
        let time : NSTimeInterval = (animated) ? 0.25 : 0.0
        
        
        UIView.animateWithDuration(time, animations: { () -> Void in
             self.progressView.alpha = 0.0
        }) { (finished: Bool) -> Void in
            self.destroyProgressViewIfNeeded()
        }
    }
    
    func destroyProgressViewIfNeeded() {
        if progressView != nil {
            progressView.removeFromSuperview()
            progressView = nil
        }
    }
*/
    
    
    // MARK: ToolBar Methods
    
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
        
        let textToShare : String = (self.webView.title != nil) ? self.webView.title! : ""
            if let link = self.webView.URL {
                let objectsToShare = [textToShare, link]
                let safariActivity = TUSafariActivity()
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [safariActivity])
                if activityVC.respondsToSelector("popoverPresentationController") {
                    // iOS 8+
                    let presentationController = activityVC.popoverPresentationController
                    presentationController?.sourceView = view
                    presentationController?.barButtonItem = actionButton
                }
                self.presentViewController(activityVC, animated: true, completion: nil)
                
                
            }
        
    }
    
    
    
    
    func updateStateBarButton() {
        if self.webView.loading == true {
            stateButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self.webView, action: "stopLoading")
        } else {
            stateButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self.webView, action: "reload")
        }
        self.toolbarItems = [backButton, flexibleSpace, forwardButton, flexibleSpace, stateButton, flexibleSpace, actionButton]
        
    }
    
    func updateToolBarItems() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = self.webView.loading
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
        self.updateStateBarButton()
    }
    // MARK: Navigation Delegate
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.updateStateBarButton()
        self.title = self.webView.URL?.description
    }

    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = self.webView.loading
        
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.updateToolBarItems()
        self.title = self.webView.title
         progressView.setProgress(0.0, animated: false)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        self.updateToolBarItems()
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "estimatedProgress") {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
   
    



}
